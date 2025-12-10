# 🛡️ Automated Penetration Testing & SecOps Lab with n8n

Lab Environment จำลองสำหรับหลักสูตร "Automated Penetration Testing & DevSecOps with n8n" ออกแบบมาเพื่อให้ผู้เรียนสามารถฝึกเขียน Workflow ควบคุม Security Tools (Nuclei, Nmap) และโจมตีเป้าหมายจำลองได้อย่างปลอดภัยและสมจริง

## 📋 Prerequisites

- **OS**: Windows 10/11 (WSL2 - Ubuntu) หรือ Linux / macOS
- **Docker**: Docker Desktop (ตรวจสอบให้แน่ใจว่าเปิดใช้งาน WSL Integration แล้ว)
- **Architecture**: รองรับทั้ง Intel/AMD และ ARM64 (Snapdragon/Apple Silicon)
  - *หมายเหตุ: การตั้งค่านี้ปรับจูนสำหรับ ARM64*

## 📂 Project Structure

โครงสร้างไฟล์และโฟลเดอร์ที่ต้องเตรียม:

```
n8n-secops-lab/
├── .env                  # เก็บ Password และ Token ลับ
├── Dockerfile            # Config สำหรับสร้าง n8n Image ที่ฝัง Security Tools
├── docker-compose.yml    # Script หลักสำหรับรัน Lab ทั้งหมด
└── vulnerable_data/      # โฟลเดอร์จำลองไฟล์ของเหยื่อ
    └── .env              # ไฟล์ความลับที่สร้างหลอกไว้ให้ Hack
```

## 🚀 Installation & Setup

### 1. สร้าง Environment Variable (.env)

สร้างไฟล์ `.env` ในโฟลเดอร์ root ของโปรเจค โดยมีตัวแปรดังนี้:

```bash
# n8n Configuration
N8N_HOST=localhost
N8N_PORT=5678
N8N_USER=admin
N8N_PASS=your_secure_password_here
WEBHOOK_URL=http://localhost:5678/

# Database Configuration
DB_NAME=n8n
DB_USER=n8n_user
DB_PASS=your_db_password_here

# Cloudflare Tunnel (Optional - สำหรับเปิด n8n ผ่าน Internet)
CF_TUNNEL_TOKEN=your_cloudflare_tunnel_token_here
```

**หมายเหตุ**: 
- เปลี่ยน `N8N_PASS` และ `DB_PASS` เป็นรหัสผ่านที่ปลอดภัย
- หากใช้ Cloudflare Tunnel ให้ใส่ `CF_TUNNEL_TOKEN` มิฉะนั้นสามารถเว้นว่างไว้ได้

### 2. สร้าง Custom Docker Image (Dockerfile)

Dockerfile จะถูกใช้โดยอัตโนมัติเมื่อรัน `docker-compose up --build` ซึ่งจะ:
- ติดตั้ง Security Tools (Nuclei, Nmap, curl, jq)
- ตั้งค่า Nuclei Templates
- ปรับสิทธิ์การเข้าถึงไฟล์

### 3. เตรียมไฟล์เหยื่อ (Victim Data)

สร้างโฟลเดอร์ `vulnerable_data` และไฟล์ `.env` ภายใน:

```bash
mkdir -p vulnerable_data
echo "SECRET_KEY=this_is_a_fake_secret_key_for_demo" > vulnerable_data/.env
echo "DB_PASSWORD=super_secret_password_123" >> vulnerable_data/.env
```

ไฟล์นี้จะถูก mount เข้าไปใน victim-app เพื่อจำลองการเปิดเผยไฟล์ความลับ

### 4. สร้าง Infrastructure (docker-compose.yml)

ไฟล์ `docker-compose.yml` จะสร้าง Services ดังนี้:
- **n8n-secops**: n8n instance พร้อม Security Tools
- **victim-app**: Nginx server ที่เปิดเผยไฟล์ความลับ
- **postgres-db**: PostgreSQL database สำหรับ n8n
- **cloudflared-tunnel**: Cloudflare Tunnel (optional)

## ⚡ Running the Lab

### เริ่มต้นระบบ (Start)

คำสั่งนี้จะ Build Image ใหม่และรัน Container ทั้งหมด:

```bash
docker-compose up -d --build
```

### หยุดระบบ (Stop)

```bash
docker-compose down
```

### หยุดและล้างระบบ (Stop & Clean)

หากต้องการล้างค่าเริ่มต้นใหม่ทั้งหมด (แนะนำเมื่อแก้ Dockerfile):

```bash
docker-compose down --rmi local
```

## ✅ Verification (Pre-flight Check)

ก่อนเริ่มสอน ให้ตรวจสอบความพร้อมของระบบ:

### Check Nuclei Version

ต้องขึ้น v3.x.x:

```bash
docker exec -it n8n-secops nuclei -version
```

### Check Victim Visibility

ต้องเห็นข้อมูลในไฟล์ `.env`:

```bash
docker exec -it n8n-secops curl http://victim-app/.env
```

### Access n8n UI

เปิด Browser ไปที่: **http://localhost:5678**

- Username: ตามที่ตั้งใน `N8N_USER` (default: `admin`)
- Password: ตามที่ตั้งใน `N8N_PASS`

## 🛠️ Usage Tips for Class

### Target URL

ใน n8n ให้ใส่ URL เป้าหมายเป็น `http://victim-app` (ไม่ต้องใช้ localhost) เพราะ Container อยู่ใน Network เดียวกัน

### Updating Templates

หากต้องการอัปเดตฐานข้อมูลช่องโหว่ ให้ใช้ Node Execute Command สั่ง:

```bash
nuclei -update-templates
```

### Running Security Scans

ตัวอย่างคำสั่งที่ใช้ใน n8n Execute Command Node:

**Nuclei Scan:**
```bash
nuclei -u http://victim-app -t /home/node/nuclei-templates/
```

**Nmap Scan:**
```bash
nmap -sV -sC victim-app
```

## 🔧 Troubleshooting

### Error: exec format error

แสดงว่าโหลด Nuclei ผิดรุ่น (AMD64 vs ARM64) ให้แก้ Dockerfile แล้ว Rebuild ใหม่:

```bash
docker-compose down --rmi local
docker-compose up -d --build
```

### Container ไม่สามารถเชื่อมต่อกันได้

ตรวจสอบว่า Network `secops_net` ถูกสร้างแล้ว:

```bash
docker network ls | grep secops_net
```

### n8n UI ไม่เปิด

ตรวจสอบว่า Port ถูกใช้งานหรือไม่:

```bash
docker ps | grep n8n-secops
```

ตรวจสอบ Logs:

```bash
docker logs n8n-secops
```

## 📚 Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Nuclei Documentation](https://docs.nuclei.sh/)
- [Nmap Documentation](https://nmap.org/book/)

---

**หมายเหตุ**: Lab นี้ใช้สำหรับการศึกษาเท่านั้น กรุณาใช้อย่างมีความรับผิดชอบและในสภาพแวดล้อมที่ควบคุมได้เท่านั้น
