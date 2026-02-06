# เอกสารกำกับ WebSecScan Pro 2026 (SecOps AI Pipeline)

เอกสารนี้อธิบายการทำงาน การตั้งค่า และวิธีใช้งานของระบบ **Advanced SecOps AI Pipeline** ซึ่งเป็นระบบอัตโนมัติสำหรับการสแกนความปลอดภัยทางไซเบอร์ โดยใช้ AI Agent ในการควบคุมเครื่องมือทดสอบเจาะระบบ (Kali Linux) และรายงานผลผ่าน Discord

## 1. ภาพรวมสถาปัตยกรรม (System Architecture)

ระบบประกอบด้วย 2 Workflows หลักที่ทำงานร่วมกัน:

1.  **Advanced SecOps AI Pipeline `(Main Workflow)`**:
    *   เป็นสมองหลักของระบบ ประกอบด้วย AI Agents 2 ตัว
    *   **Orchestrator Agent**: ทำหน้าที่วางแผนการสแกน ตัดสินใจเลือกใช้เครื่องมือ (Nmap, Nuclei, Metasploit) และควบคุมขั้นตอนการทำงาน (Recon -> Scan -> Verify)
    *   **Reporter Agent**: ทำหน้าที่สรุปผลลัพธ์ทางเทคนิคให้อยู่ในรูปแบบรายงานภาษาไทยระดับมืออาชีพ
    *   **Integration**: เชื่อมต่อกับ Chat Trigger (รับคำสั่ง) และ Discord (ส่งผลลัพธ์)

2.  **Kali Executor Tool `(Sub-workflow)`**:
    *   ทำหน้าที่เป็น "แขนขา" ในการรันคำสั่งจริง
    *   รับคำสั่ง Bash Command จาก Orchestrator
    *   เชื่อมต่อผ่าน SSH เข้าไปที่ Kali Linux Container เพื่อรันคำสั่ง
    *   ส่งผลลัพธ์ (Stdout) กลับมาให้ AI

---

## 2. รายละเอียด Workflow หลัก (Advanced SecOps AI Pipeline)

**ไฟล์:** `Advanced SecOps AI Pipeline.json`

### 2.1 Node สำคัญ
*   **Chat Trigger**: จุดเริ่มต้นรับคำสั่งจากผู้ใช้ (ผ่านหน้า n8n UI หรือ API)
*   **Orchestrator Agent**: 
    *   **Model**: OpenRouter (Google Gemini 2.0 Flash) - เร็วและฉลาดพอสำหรับการวางแผน
    *   **System Prompt**: ถูกปรับแต่งให้ทำงานเป็น "Lead Security Orchestrator" ตามโปรโตคอล WebSecScan Pro 2026
    *   **Tools**: เรียกใช้ `Kali Executor Tool` เพื่อรันคำสั่ง
*   **KaliCLI (Tool Node)**: จุดเชื่อมต่อไปยัง Sub-workflow
*   **JSON Parser**: แปลงผลลัพธ์การสแกนให้อยู่ในรูปแบบ JSON Structure ที่กำหนดไว้แน่นอน (Schema)
*   **Reporter Agent**:
    *   **Model**: OpenRouter (Google Gemini 2.0 Flash หรือ Moonshot Kimi)
    *   **Prompt**: สั่งให้สรุปรายงานเป็นภาษาไทย แบ่งหัวข้อชัดเจน (บทสรุปผู้บริหาร, สิ่งที่ตรวจพบ, คำแนะนำ)
*   **Create Report File**: โค้ด JavaScript สำหรับแปลงข้อความรายงานให้เป็นไฟล์ `security_report.md` (แก้ปัญหาข้อความยาวเกิน Limit ของ Discord)
*   **Discord Alert**: ส่งไฟล์รายงานเข้าสู่ห้องแชทผ่าน Webhook

### 2.2 การไหลของข้อมูล (Data Flow)
1.  **User** พิมพ์คำสั่ง -> **Orchestrator** วิเคราะห์
2.  **Orchestrator** สั่งรัน Nmap/Nuclei -> **Kali Executor** -> **Kali Linux**
3.  **Kali Linux** ส่งผล Scan กลับ -> **Orchestrator** รวบรวม
4.  **Orchestrator** ส่ง JSON Findings -> **Reporter**
5.  **Reporter** เขียนรายงานภาษาไทย -> **Create File** -> **Discord**

---

## 3. รายละเอียด Workflow ย่อย (Kali Executor Tool)

**ไฟล์:** `Kali Executor Tool.json`

### 3.1 การทำงาน
*   **Execute Workflow Trigger**: รอรับการเรียกใช้งานจาก Main Workflow
*   **SSH Node**:
    *   **Host**: `kali-linux` (ชื่อ Service ใน Docker Compose)
    *   **Command**: `{{ $json.query }}` (รับคำสั่ง Dynamic)
    *   **Authentication**: ใช้ SSH Password (user: `root`, pass: `kali`)

---

## 4. การตั้งค่าที่จำเป็น (Configuration)

เพื่อให้ระบบทำงานได้ ต้องตั้งค่า Credentials ใน n8n ดังนี้:

| Credential Name | Type | Description |
| :--- | :--- | :--- |
| **OpenRouter account** | OpenRouter API | API Key สำหรับใช้งาน AI Model (Gemini/Kimi) |
| **SSH Password account** | SSH Password | สำหรับเชื่อมต่อ Kali (User: `root`, Pass: `kali`) |
| **Discord Webhook account** | Discord Webhook | Webhook URL ของห้อง Discord ที่ต้องการรับรายงาน |

---

## 5. ตัวอย่าง Prompt สำหรับทดสอบ (Test Scenarios)

คุณสามารถนำ Prompt เหล่านี้ไปวางในช่อง Chat ของ Workflow เพื่อทดสอบระบบ:

### **Scenario 1: สแกนเป้าหมายพื้นฐาน (Basic Scan)**
> "ช่วยสแกนเครื่อง juice-shop-victim ที่พอร์ต 3000 ให้หน่อย ตรวจสอบ tech stack และหาช่องโหว่พื้นฐาน สรุปผลเป็นภาษาไทย"

### **Scenario 2: ทดสอบช่องโหว่เจาะจง (Targeted Vulnerability)**
> "ตรวจสอบ metasploitable-victim ที่พอร์ต 21 (FTP) ว่ามี Backdoor CVE-2011-2523 หรือไม่ ถ้ามีให้ลองยืนยันด้วย Metasploit check module แล้วรายงานผลความเสี่ยง"

### **Scenario 3: สแกนเต็มรูปแบบตามมาตรฐาน (Full ASVS Scan)**
> "เริ่มกระบวนการ WebSecScan Pro บน metasploitable-victim โดยเน้นการตรวจสอบตาม OWASP Top 10 วิเคราะห์ Service ที่เปิดอยู่ทั้งหมด และประเมินระดับความปลอดภัยตามมาตรฐาน ASVS พร้อมคำแนะนำในการแก้ไข"

---

## 6. การแก้ไขปัญหาเบื้องต้น (Troubleshooting)

*   **Error: Workflow is not active**: ตรวจสอบว่า `Kali Executor Tool` ถูก Activate (เปิดใช้งาน) แล้วหรือยัง
*   **Discord ไม่ส่งข้อความ**: ตรวจสอบ Webhook URL และเช็คว่าโหมดส่งข้อความไม่ใช่ Bot Token
*   **AI ตอบวนลูป**: อาจเกิดจาก Prompt ไม่ชัดเจน หรือ AI พยายามรันคำสั่งเดิมซ้ำๆ (Orchestrator มีการจำกัด Step ไว้ที่ 3 เพื่อป้องกันปัญหานี้)
