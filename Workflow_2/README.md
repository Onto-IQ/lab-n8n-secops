# WebSecScan Pro - ระบบสแกนความปลอดภัยเว็บด้วย Multi-Agent AI (ฉบับอัปเดต 2026)

เอกสารนี้อธิบายสถาปัตยกรรมและการใช้งานของระบบ **WebSecScan Pro** ซึ่งเป็นระบบ Multi-Agent AI ที่ทำงานบน n8n เพื่อตรวจสอบความปลอดภัยของเว็บไซต์ตามมาตรฐาน OWASP ASVS

## 1. ภาพรวมสถาปัตยกรรม (Architecture Overview)

ระบบถูกออกแบบโดยใช้ **Orchestrator-Workers Pattern** โดยมี Orchestrator เป็นผู้สั่งการ และมี Sub-Agents ที่มีความเชี่ยวชาญเฉพาะด้านทำงานเบื้องหลังผ่าน Workflow Tools

### แผนภาพการทำงาน
```mermaid
graph TD
    User[ผู้ใช้งาน] -->|กรอก URL ผ่าน Form| Trigger(Form Trigger)
    Trigger --> Orchestrator[Orchestrator Agent<br/>(Claude 3.5 Sonnet)]
    
    subgraph "Orchestrator Workflow"
        Orchestrator -->|เรียกใช้ Tool| ToolRecon[Recon Tool]
        Orchestrator -->|เรียกใช้ Tool| ToolTransport[Transport Security Tool]
        Orchestrator -->|เรียกใช้ Tool| ToolIdentity[Identity Tool]
        Orchestrator -->|เรียกใช้ Tool| ToolCorrelation[Correlation Tool]
        
        Orchestrator -->|ส่งผลลัพธ์| CreateFile[สร้างไฟล์รายงาน .md]
        CreateFile -->|อัปโหลดไฟล์| Discord[Discord Webhook]
    end
    
    subgraph "Sub-Agent Worker Workflow"
        ToolRecon -.->|Execute Workflow| Worker[Sub-Agent AI Worker<br/>(Claude 3.5 Sonnet)]
        ToolTransport -.->|Execute Workflow| Worker
        ToolIdentity -.->|Execute Workflow| Worker
        ToolCorrelation -.->|Execute Workflow| Worker
        
        Worker -->|คืนผลลัพธ์| Orchestrator
    end
```

---

## 2. รายละเอียดของ Agents

ระบบประกอบด้วย Agent หลักและ Agent ย่อยดังนี้:

### 2.1 Orchestrator Agent (ผู้ควบคุม)
*   **หน้าที่**: รับ Input (URL), วางแผนการสแกน, เรียกใช้งาน Sub-Agents ตามลำดับ, และรวบรวมผลลัพธ์เพื่อสร้างรายงานสรุป
*   **Model**: Anthropic Claude 3.5 Sonnet (ผ่าน OpenRouter)
*   **ความสามารถหลัก**: แปลงผลลัพธ์ทางเทคนิคทั้งหมดให้เป็น **รายงานภาษาไทย** ที่เข้าใจง่ายแต่คงศัพท์เทคนิคไว้

### 2.2 Sub-Agents (ผู้ปฏิบัติงาน)
ทำงานผ่าน **Workflow Tool** (`@n8n/n8n-nodes-langchain.toolWorkflow`) โดยส่งงานไปที่ Workflow กลาง (`WebSec_SubAgent_Worker`) ซึ่งจะสวมบทบาทตามที่ได้รับมอบหมาย:

1.  **Reconnaissance Agent**: ตรวจสอบ Tech Stack, CMS, และประเมินระดับความปลอดภัยเบื้องต้น (ASVS Level)
2.  **Transport Security Agent**: ตรวจสอบความปลอดภัยของการรับส่งข้อมูล (TLS, HSTS, Headers)
3.  **Identity & Access Agent**: ตรวจสอบระบบยืนยันตัวตนและการจัดการสิทธิ์ (AuthN/AuthZ)
4.  **Correlation Agent**: วิเคราะห์ความเชื่อมโยงของช่องโหว่ (Attack Chain) และจัดลำดับความสำคัญ

---

## 3. การติดตั้งและการทำงาน (Implementation Details)

ระบบปัจจุบันถูกติดตั้งและพร้อมใช้งานบน n8n โดยแบ่งเป็น 2 Workflows หลัก:

### 3.1 Main Orchestrator Workflow
*   **ชื่อ**: `WebSecScan Pro - Workflow Tools Edition`
*   **ID**: `xcv9j8hu2oqy7LoB`
*   **Trigger**: `Form Trigger` (สร้างหน้าเว็บฟอร์มให้กรอก URL)
*   **Output**: ส่งรายงานเป็นไฟล์ **Markdown (.md)** ไปยัง Discord
*   **การเชื่อมต่อ**: ใช้ Workflow Tools ในการเชื่อมต่อไปยัง Worker

### 3.2 Sub-Agent Worker Workflow
*   **ชื่อ**: `WebSec_SubAgent_Worker`
*   **ID**: `hnStxD29gy2uauhe`
*   **Trigger**: `Execute Workflow Trigger` (รอรับคำสั่งจาก Main Workflow)
*   **Logic**: เป็น AI Agent ตัวเดียวที่รับ Parameter (`role`, `task`, `target`) แล้วเปลี่ยนบทบาทไปตามคำสั่งนั้นๆ เพื่อความประหยัดและง่ายต่อการดูแลรักษา

---

## 4. วิธีการใช้งาน (How to Run)

1.  เปิด Workflow **"WebSecScan Pro - Workflow Tools Edition"** ใน n8n
2.  ตรวจสอบการตั้งค่า **Discord Node**:
    *   คลิกที่โหนด `Send Report to Discord`
    *   ตรวจสอบว่าเลือก **Credential** (Discord Webhook account) ถูกต้องแล้ว
3.  กดปุ่ม **Execute Workflow** ด้านล่าง
4.  คลิกที่โหนดแรก **Start Audit Form** แล้วกดปุ่ม **Test URL** (หรือ Open URL)
5.  ในหน้าเว็บที่เปิดขึ้นมา:
    *   กรอก **Target URL** (เว็บไซต์ที่ต้องการสแกน เช่น `https://example.com`)
    *   กด **Submit**
6.  รอสักครู่... ระบบจะทำการวิเคราะห์และส่งไฟล์รายงาน `WebSecScan_Report.md` (ภาษาไทย) ไปยังห้อง Discord ของคุณ

---

## 5. หมายเหตุ (Notes)
*   **Credential**: ระบบใช้ Discord Webhook Credential ที่มีอยู่แล้ว ไม่ต้องแก้ไขประเภท Authentication
*   **Output Format**: รายงานถูกตั้งค่าให้ส่งเป็นไฟล์แนบ `.md` เพื่อหลีกเลี่ยงข้อจำกัดจำนวนตัวอักษรของ Discord (2,000 chars) และเพื่อให้ได้รายงานที่ละเอียดครบถ้วนที่สุด
