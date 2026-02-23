# 🛡️ Automated Penetration Testing & SecOps Lab with n8n

> **Lab Environment สำหรับการศึกษา** - ระบบจำลองสภาพแวดล้อมสำหรับหลักสูตร "Automated Penetration Testing & DevSecOps with n8n" ออกแบบมาเพื่อให้ผู้เรียนสามารถฝึกเขียน Workflow ควบคุม Security Tools (Nuclei, Nmap) และทดสอบเป้าหมายจำลองได้อย่างปลอดภัยและสมจริง

---

## 📑 สารบัญ

- [ภาพรวม](#-ภาพรวม)
- [คุณสมบัติหลัก](#-คุณสมบัติหลัก)
- [ความต้องการของระบบ](#-ความต้องการของระบบ)
- [โครงสร้างโปรเจกต์](#-โครงสร้างโปรเจกต์)
- [การติดตั้งและตั้งค่า](#-การติดตั้งและตั้งค่า)
- [การใช้งาน](#-การใช้งาน)
- [SecOps Demo Workflow](#-secops-demo-workflow)
- [การตรวจสอบระบบ](#-การตรวจสอบระบบ)
- [การแก้ไขปัญหา](#-การแก้ไขปัญหา)
- [เอกสารอ้างอิง](#-เอกสารอ้างอิง)
- [ข้อกำหนดและข้อจำกัด](#-ข้อกำหนดและข้อจำกัด)

---

## 🎯 ภาพรวม

โปรเจกต์นี้เป็น Lab Environment ที่ออกแบบมาเพื่อการศึกษาและฝึกอบรมด้าน Security Operations (SecOps) โดยใช้ n8n เป็น Orchestration Platform ในการควบคุม Security Tools ต่างๆ เช่น Nuclei และ Nmap เพื่อทำการ Automated Penetration Testing บนเป้าหมายจำลองที่ปลอดภัย

### สถาปัตยกรรมระบบ

```
┌─────────────────┐
│   n8n-secops    │  ← Orchestration Platform
│   (Attacker)    │
└────────┬────────┘
         │
         ├───┐
         │   │
    ┌────▼───▼────────────────────────────────────┐
    │           Vulnerable Targets                  │
    │  ┌─────────────┐  ┌──────────────┐          │
    │  │  victim-app │  │  juice-shop  │          │
    │  │   (Nginx)   │  │  (OWASP)     │          │
    │  └─────────────┘  └──────────────┘          │
    │  ┌─────────────────────────────────┐        │
    │  │      metasploitable-victim      │        │
    │  └─────────────────────────────────┘        │
    └─────────────────────────────────────────────┘
         │
    ┌────▼────┐     ┌──────────────┐
    │ postgres│     │ kali-linux   │ ← Security Tools
    │ (DB)    │     │ (Executor)   │   (Nmap, Nuclei, Metasploit)
    └─────────┘     └──────────────┘
         │
    ┌────▼────────┐
    │ cloudflared │ ← Cloudflare Tunnel (Optional)
    └─────────────┘
```

---

## ✨ คุณสมบัติหลัก

- **🔧 Security Tools Integration**: Nuclei, Nmap, Metasploit พร้อมใช้งานใน Kali Container
- **🤖 AI-Powered Automation**: ใช้ OpenAI เพื่อแปลง Natural Language เป็น Security Commands
- ** Docker-Based Environment**: รันได้บนทุก Platform (Windows/Linux/macOS, ARM64/AMD64)
- **🔒 Isolated Network**: ใช้ Docker Network (`secops_net`) แยกระบบทดสอบออกจากระบบจริง
- **🎯 Multiple Targets**: รองรับการทดสอบบน victim-app, OWASP Juice Shop, และ Metasploitable2
- **📊 Automated Reporting**: สร้างรายงานสรุปผลการสแกนอัตโนมัติด้วย AI

---

## 📋 ความต้องการของระบบ

### ระบบปฏิบัติการ

- **Windows 10/11** (ต้องใช้ WSL2 - Ubuntu)
- **Linux** (Ubuntu 20.04+ หรือเทียบเท่า)
- **macOS** (10.15+)

### ซอฟต์แวร์ที่จำเป็น

| ซอฟต์แวร์ | เวอร์ชันขั้นต่ำ | หมายเหตุ |
|-----------|----------------|----------|
| Docker | 20.10+ | ต้องเปิดใช้งาน WSL Integration (Windows) |
| Docker Compose | 2.0+ | รวมอยู่ใน Docker Desktop |
| Git | 2.30+ | สำหรับ Clone Repository |

### สถาปัตยกรรมที่รองรับ

- **Intel/AMD (x86_64)**
- **ARM64** (Apple Silicon, Snapdragon)

> **หมายเหตุ**: การตั้งค่าในโปรเจกต์นี้ปรับจูนสำหรับ ARM64 โดยเฉพาะ

---

## 📂 โครงสร้างโปรเจกต์

```
n8n-secops-lab/
├── .env                      # Environment Variables (ไม่ถูก commit)
├── .env.example              # ตัวอย่าง Environment Variables
├── Dockerfile.n8n           # Custom n8n Image
├── Dockerfile.kali          # Kali Linux with Security Tools
├── docker-compose.yml        # Docker Compose Configuration (7 services)
├── workflows/                # Additional workflow files
│   ├── Advanced_SecOps_AI_Pipeline.json
│   └── Kali_Executor_Tool.json
├── Workflow_1/               # SecOps Workflow Set 1
│   ├── Advanced SecOps AI Pipeline.json
│   ├── Kali Executor Tool.json
│   └── README.md
├── Workflow_2/               # SecOps Workflow Set 2
│   ├── WebSecScan Pro - Workflow Tools Edition.json
│   ├── WebSec_SubAgent_Worker.json
│   └── README.md
├── README.md                 # เอกสารนี้
└── vulnerable_data/          # Vulnerable Target Data
    └── .env                  # ไฟล์จำลองที่เปิดเผย (สำหรับ Demo)
```

### คำอธิบายไฟล์สำคัญ

- **`Dockerfile.n8n`**: สร้าง Custom n8n Image
- **`Dockerfile.kali`**: สร้าง Kali Linux Container พร้อม Security Tools (Nmap, Nuclei, Metasploit)
- **`docker-compose.yml`**: กำหนด Services ทั้งหมด 7 ตัว (n8n, victim-app, postgres, kali, cloudflared, juice-shop, metasploitable)
- **`Workflow_1/`**: Workflow ชุดที่ 1 - Advanced SecOps AI Pipeline + Kali Executor
- **`Workflow_2/`**: Workflow ชุดที่ 2 - WebSecScan Pro + SubAgent Worker
- **`workflows/`**: Workflow files สำรอง
- **`vulnerable_data/.env`**: ไฟล์จำลองที่เปิดเผยเพื่อใช้ในการทดสอบ

---

## 🚀 การติดตั้งและตั้งค่า

### ขั้นตอนที่ 1: Clone Repository

```bash
git clone <repository-url>
cd n8n-secops-lab
```

### ขั้นตอนที่ 2: สร้าง Environment Variables

คัดลอกไฟล์ `.env.example` เป็น `.env`:

```bash
cp .env.example .env
```

แก้ไขไฟล์ `.env` และตั้งค่าตัวแปรต่อไปนี้:

| ตัวแปร | คำอธิบาย | ตัวอย่าง |
|--------|----------|----------|
| `N8N_USER` | Username สำหรับเข้าสู่ระบบ n8n | `admin` |
| `N8N_PASS` | Password สำหรับเข้าสู่ระบบ n8n | `your_secure_password` |
| `N8N_PORT` | Port สำหรับ n8n Web UI | `5678` |
| `N8N_HOST` | Host สำหรับ n8n | `localhost` |
| `WEBHOOK_URL` | Webhook URL (สำหรับ Cloudflare Tunnel) | `http://localhost:5678` |
| `DB_USER` | Username สำหรับ PostgreSQL | `n8n` |
| `DB_PASS` | Password สำหรับ PostgreSQL | `your_db_password` |
| `DB_NAME` | Database name | `n8n` |
| `CF_TUNNEL_TOKEN` | Cloudflare Tunnel Token (Optional) | _(เว้นว่างได้)_ |

> **⚠️ คำเตือน**: ไฟล์ `.env` จะไม่ถูก commit ขึ้น Repository เพื่อความปลอดภัย

### ขั้นตอนที่ 3: เตรียม Vulnerable Data

สร้างโฟลเดอร์และไฟล์สำหรับเป้าหมายจำลอง:

```bash
mkdir -p vulnerable_data
cat > vulnerable_data/.env << EOF
SECRET_KEY=this_is_a_fake_secret_key_for_demo
DB_PASSWORD=super_secret_password_123
API_KEY=demo_api_key_12345
EOF
```

### ขั้นตอนที่ 4: Build และ Start Services

รันคำสั่งต่อไปนี้เพื่อ Build Docker Images และ Start Services:

```bash
docker-compose up -d --build
```

คำสั่งนี้จะ:
1. Build Custom n8n Image (ติดตั้ง Security Tools)
2. สร้าง Docker Network (`secops_net`)
3. Start Services ทั้งหมด (n8n, victim-app, postgres)

### ขั้นตอนที่ 5: ตรวจสอบสถานะ

ตรวจสอบว่า Services ทั้งหมดรันอยู่:

```bash
docker-compose ps
```

ควรเห็น Services ทั้งหมดมีสถานะ `Up`

---

## 💻 การใช้งาน

### เข้าถึง n8n Web UI

1. เปิด Browser ไปที่: **http://localhost:5678**
2. Login ด้วย:
   - **Username**: ตามที่ตั้งใน `N8N_USER` (default: `admin`)
   - **Password**: ตามที่ตั้งใน `N8N_PASS`

### การจัดการ Workflow

#### Import Workflow

1. คลิก **Workflows** → **Import from File**
2. เลือกไฟล์ workflow จากโฟลเดอร์:
   - `Workflow_1/Advanced SecOps AI Pipeline.json`
   - `Workflow_1/Kali Executor Tool.json`
   - `Workflow_2/WebSecScan Pro - Workflow Tools Edition.json`
   - `Workflow_2/WebSec_SubAgent_Worker.json`
3. Workflow จะถูก Import เข้ามาในระบบ

**หมายเหตุ**: ไฟล์ในโฟลเดอร์ `workflows/` เป็นรูปแบบ snake_case เช่น `Advanced_SecOps_AI_Pipeline.json`

#### Activate Workflow

1. เปิด Workflow ที่ต้องการ
2. คลิก **Active** toggle ที่มุมบนขวา
3. Workflow จะเริ่มทำงานและรอรับ Trigger

### คำสั่งที่ใช้บ่อย

#### เข้าใช้งาน Kali Linux Container

```bash
# SSH เข้า Kali Container (จาก n8n container)
docker exec -it n8n-secops ssh root@kali-linux
# Password: kali

# หรือเข้าตรงผ่าน Docker Exec
docker exec -it kali-linux bash
```

#### อัปเดต Nuclei Templates

```bash
docker exec -it kali-linux nuclei -update-templates
```

#### ตรวจสอบ Version ของ Tools

```bash
# ตรวจสอบ Nuclei Version
docker exec -it kali-linux nuclei -version

# ตรวจสอบ Nmap Version
docker exec -it kali-linux nmap --version

# ตรวจสอบ Metasploit
docker exec -it kali-linux msfconsole --version
```

#### ทดสอบการเชื่อมต่อ

```bash
# ทดสอบการเชื่อมต่อไปยัง victim-app
docker exec -it n8n-secops curl http://victim-app/.env

# ทดสอบ juice-shop
docker exec -it n8n-secops curl http://juice-shop-victim:3000

# ทดสอบ metasploitable
docker exec -it kali-linux ping -c 3 metasploitable-victim
```

### ตัวอย่างคำสั่ง Security Scan

#### Nmap Scan (บน Kali Container)

```bash
# Fast Scan
docker exec -it kali-linux nmap -F -T4 victim-app

# Full Scan with Service Detection
docker exec -it kali-linux nmap -sV -sC victim-app

# Scan Specific Ports
docker exec -it kali-linux nmap -p 80,443,8080 victim-app

# Scan Multiple Targets
docker exec -it kali-linux nmap -F juice-shop-victim metasploitable-victim
```

#### Nuclei Scan (บน Kali Container)

```bash
# Basic Scan
docker exec -it kali-linux nuclei -u http://victim-app -silent

# Scan with Specific Tags
docker exec -it kali-linux nuclei -u http://victim-app -tags exposure -silent

# JSON Output
docker exec -it kali-linux nuclei -u http://victim-app -json -silent

# Scan juice-shop
docker exec -it kali-linux nuclei -u http://juice-shop-victim:3000 -silent
```

> **💡 เคล็ดลับ**: ใน n8n ให้ใช้ชื่อ Container เป็น hostname เช่น `victim-app`, `juice-shop-victim`, `metasploitable-victim` เพราะอยู่ใน Docker Network เดียวกัน

---

## 🔄 SecOps Demo Workflows

โปรเจกต์นี้มี Workflow ตัวอย่าง 2 ชุดในโฟลเดอร์ `Workflow_1/` และ `Workflow_2/`:

### Workflow 1: Advanced SecOps AI Pipeline

**ไฟล์**: `Workflow_1/Advanced SecOps AI Pipeline.json`

Workflow ตัวอย่างที่แสดงการใช้งาน AI-Powered Security Automation:

1. **รับคำสั่ง Natural Language** ผ่าน Webhook หรือ Chat
2. **แปลงคำสั่งเป็น Security Commands** ด้วย AI
3. **สแกน Ports** ด้วย Nmap และ Parse ผลลัพธ์
4. **เตรียม Targets** สำหรับ Nuclei อัตโนมัติ
5. **สแกนช่องโหว่** ด้วย Nuclei
6. **สร้างรายงาน** ด้วย AI

**รายละเอียดเพิ่มเติม**: ดูที่ `Workflow_1/README.md`

### Workflow 2: WebSecScan Pro

**ไฟล์**: `Workflow_2/WebSecScan Pro - Workflow Tools Edition.json`

Workflow สำหรับ Web Security Scanning ด้วย SubAgent Worker:

- **Multi-target Scanning**: รองรับการสแกนหลายเป้าหมายพร้อมกัน
- **SubAgent Pattern**: ใช้ Worker Node สำหรับประมวลผลแบบขนาน
- **Automated Reporting**: สร้างรายงานรวมผลการสแกน

**รายละเอียดเพิ่มเติม**: ดูที่ `Workflow_2/README.md`

### Kali Executor Tool

**ไฟล์**: `Workflow_1/Kali Executor Tool.json` และ `workflows/Kali_Executor_Tool.json`

Workflow สำหรับ Execute Security Commands บน Kali Linux Container ผ่าน SSH:

- รันคำสั่ง Nmap, Nuclei, Metasploit บน Kali Container
- รองรับการทำงานผ่าน SSH Connection
- เก็บผลลัพธ์กลับมาประมวลผลใน n8n

### ฟีเจอร์หลัก

| ฟีเจอร์ | คำอธิบาย |
|---------|----------|
| **Natural Language Processing** | รับคำสั่งภาษาไทย/อังกฤษและแปลงเป็น Security Commands |
| **Intelligent Port Detection** | ตรวจจับ Ports ที่เปิดและสร้าง URL Targets อัตโนมัติ |
| **Automated Vulnerability Scanning** | สแกนช่องโหว่ด้วย Nuclei (focus: exposure tags) |
| **AI-Powered Reporting** | สร้างรายงานสรุปผลการสแกน |
| **Kali Linux Integration** | Execute commands บน Kali Container ผ่าน SSH |
| **Multi-Target Support** | รองรับการสแกนหลายเป้าหมายพร้อมกัน |

---

## ✅ การตรวจสอบระบบ

### Pre-flight Checklist

ก่อนเริ่มใช้งาน ให้ตรวจสอบความพร้อมของระบบ:

#### 1. ตรวจสอบ Services ทั้งหมด

```bash
docker-compose ps
```

**ผลลัพธ์ที่คาดหวัง**: ควรเห็น 7 Services ในสถานะ `Up`:
- n8n-secops
- victim-app
- postgres-db
- kali-linux
- cloudflared-tunnel
- juice-shop-victim
- metasploitable-victim

#### 2. ตรวจสอบ Nuclei Version (ใน Kali Container)

```bash
docker exec -it kali-linux nuclei -version
```

**ผลลัพธ์ที่คาดหวัง**: `v3.x.x`

#### 3. ตรวจสอบ Victim Apps Accessibility

```bash
# ทดสอบ victim-app (Nginx)
docker exec -it n8n-secops curl http://victim-app/.env

# ทดสอบ juice-shop
docker exec -it n8n-secops curl http://juice-shop-victim:3000 -I

# ทดสอบ metasploitable (ตรวจสอบว่าเปิด ports)
docker exec -it kali-linux nmap -sn metasploitable-victim
```

#### 4. ตรวจสอบ Kali Linux SSH

```bash
docker exec -it kali-linux pgrep sshd
```

**ผลลัพธ์ที่คาดหวัง**: ควรเห็น Process ID ของ SSH daemon

#### 5. ตรวจสอบ Network Connectivity

```bash
docker network inspect secops_net
```

**ผลลัพธ์ที่คาดหวัง**: ควรเห็น Containers ทั้งหมด 7 ตัวเชื่อมต่ออยู่ใน Network เดียวกัน

#### 6. ตรวจสอบ n8n UI

เปิด Browser ไปที่ **http://localhost:5678** และ Login

**ผลลัพธ์ที่คาดหวัง**: ควรเข้าสู่ระบบได้และเห็น Dashboard

---

## 🔧 การแก้ไขปัญหา

### ปัญหาที่พบบ่อย

#### Error: exec format error

**สาเหตุ**: Nuclei Binary ไม่ตรงกับ Architecture (AMD64 vs ARM64)

**วิธีแก้ไข**:
```bash
docker-compose down --rmi local
docker-compose up -d --build
```

#### Container ไม่สามารถเชื่อมต่อกันได้

**สาเหตุ**: Docker Network ยังไม่ถูกสร้าง

**วิธีแก้ไข**:
```bash
# ตรวจสอบ Network
docker network ls | grep secops_net

# สร้าง Network ใหม่ (ถ้ายังไม่มี)
docker network create secops_net

# Restart Services
docker-compose restart
```

#### n8n UI ไม่เปิด

**วิธีแก้ไข**:

1. **ตรวจสอบ Port ถูกใช้งานหรือไม่**:
   ```bash
   docker ps | grep n8n-secops
   netstat -tuln | grep 5678
   ```

2. **ตรวจสอบ Logs**:
   ```bash
   docker logs n8n-secops
   ```

3. **Restart Container**:
   ```bash
   docker-compose restart n8n
   ```

#### Kali Linux SSH เข้าไม่ได้

**สาเหตุ**: SSH Service ยังไม่เริ่มทำงาน

**วิธีแก้ไข**:
```bash
# ตรวจสอบสถานะ SSH
docker exec kali-linux pgrep sshd

# ถ้าไม่มี Process ให้ restart container
docker-compose restart kali

# หรือ start SSH ด้วยตนเอง
docker exec kali-linux /usr/sbin/sshd -D &
```

**หมายเหตุ**: Default password สำหรับ root คือ `kali` (เปลี่ยนได้ใน `Dockerfile.kali`)

#### Nuclei ไม่พบช่องโหว่

**สาเหตุ**: Nuclei templates อาจไม่ได้อัปเดต หรือ target ไม่มีช่องโหว่ที่ตรวจพบ

**วิธีแก้ไข**:

1. **อัปเดต Templates**:
   ```bash
   docker exec -it kali-linux nuclei -update-templates
   ```

2. **ตรวจสอบว่า victim-app มีไฟล์ที่เปิดเผย**:
   ```bash
   docker exec -it n8n-secops curl http://victim-app/.env
   ```

3. **ทดสอบ Nuclei โดยตรง**:
   ```bash
   docker exec -it kali-linux nuclei -u http://victim-app -tags exposure -v
   ```

4. **ลองสแกน juice-shop**:
   ```bash
   docker exec -it kali-linux nuclei -u http://juice-shop-victim:3000 -v
   ```

### การตรวจสอบ Logs

#### ดู Logs ของ Service ทั้งหมด

```bash
docker-compose logs -f
```

#### ดู Logs ของ Service เฉพาะ

```bash
# n8n Logs
docker-compose logs -f n8n

# kali-linux Logs
docker-compose logs -f kali

# victim-app Logs
docker-compose logs -f victim-app

# juice-shop Logs
docker-compose logs -f juice-shop

# metasploitable Logs
docker-compose logs -f metasploitable

# postgres Logs
docker-compose logs -f postgres

# cloudflared Logs
docker-compose logs -f cloudflared
```

---

## 📚 เอกสารอ้างอิง

### เอกสารทางการ

- [n8n Documentation](https://docs.n8n.io/) - เอกสาร n8n อย่างเป็นทางการ
- [Nuclei Documentation](https://docs.nuclei.sh/) - เอกสาร Nuclei Scanner
- [Nmap Documentation](https://nmap.org/book/) - เอกสาร Nmap Network Scanner
- [Docker Documentation](https://docs.docker.com/) - เอกสาร Docker

### API Documentation

- [Line Messaging API](https://developers.line.biz/en/docs/messaging-api/) - Line Bot API
- [OpenAI API](https://platform.openai.com/docs/) - OpenAI API Reference

### เอกสารภายในโปรเจกต์

- **`Workflow_1/README.md`** - คู่มือการใช้งาน Advanced SecOps AI Pipeline
- **`Workflow_2/README.md`** - คู่มือการใช้งาน WebSecScan Pro

---

## ⚠️ ข้อกำหนดและข้อจำกัด

### ⚖️ ข้อกำหนดการใช้งาน

1. **วัตถุประสงค์**: โปรเจกต์นี้ใช้สำหรับ **การศึกษาและฝึกอบรมเท่านั้น**
2. **การใช้งาน**: ใช้ได้เฉพาะในสภาพแวดล้อมที่ควบคุมได้และได้รับอนุญาต
3. **ความรับผิดชอบ**: ผู้ใช้ต้องรับผิดชอบต่อการกระทำของตนเอง

### 🚫 สิ่งที่ห้ามทำ

- ❌ ใช้กับระบบจริงโดยไม่ได้รับอนุญาต
- ❌ ใช้เพื่อโจมตีระบบที่ไม่มีสิทธิ์เข้าถึง
- ❌ แชร์ Credentials หรือ Sensitive Data
- ❌ ใช้ใน Production Environment โดยไม่มีการปรับแต่ง Security

### 🔒 ข้อควรระวังด้านความปลอดภัย

1. **Environment Variables**: อย่า Commit ไฟล์ `.env` ขึ้น Repository
2. **Credentials**: ใช้ Password ที่แข็งแรงและไม่ซ้ำกับระบบอื่น
3. **Network Isolation**: ตรวจสอบว่า Docker Network ไม่เชื่อมต่อกับระบบจริง
4. **Access Control**: จำกัดการเข้าถึง n8n UI ด้วย Authentication

### 📝 License

โปรเจกต์นี้ใช้สำหรับการศึกษาเท่านั้น กรุณาอ่านและปฏิบัติตาม License Agreement ที่เกี่ยวข้อง

---

## 🤝 การมีส่วนร่วม

หากพบปัญหา或有ข้อเสนอแนะ กรุณา:

1. สร้าง Issue ใน Repository
2. อธิบายปัญหาหรือข้อเสนอแนะอย่างชัดเจน
3. แนบ Logs หรือ Screenshots (ถ้ามี)

---

## 📞 ติดต่อ

สำหรับคำถามหรือความช่วยเหลือ กรุณาติดต่อผ่าน:

- **Issues**: สร้าง Issue ใน Repository
- **Documentation**: อ่านเอกสารใน `Workflow_1/README.md` และ `Workflow_2/README.md`

---

<div align="center">

**⚠️ ใช้อย่างมีความรับผิดชอบ ⚠️**

*โปรเจกต์นี้ใช้สำหรับการศึกษาเท่านั้น*

</div>
