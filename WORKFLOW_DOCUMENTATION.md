# 🛡️ Advanced SecOps AI Pipeline Documentation

## 1. Overview
This project implements an **Advanced AI Security Operations (SecOps) Pipeline** using **n8n**, **Kali Linux**, and **Google Gemini AI**.
It features a **Dual-Agent Architecture** to separate orchestration/execution from reporting, ensuring high-quality, actionable intelligence.

### 🏗️ Architecture
```mermaid
graph TD
    User[User via Chat] -->|Target| Agent1[🕵️ Orchestrator Agent]
    Ag1 -->|Planning| Gemini1[Gemini 1.5 Flash]
    Ag1 -->|Execution| KaliTool[🛠️ Kali Executor Tool]
    KaliTool -->|SSH| Kali[Kali Linux Container]
    Kali -->|Scan (Nmap/Exploit)| Targets[🎯 Victim Apps (Juice Shop/Metasploitable)]
    Agent1 -->|JSON Findings| Parser[Structured Parser]
    Parser -->|Structured Data| Agent2[📝 Reporter Agent]
    Agent2 -->|Drafting| Gemini2[Gemini 1.5 Flash]
    Agent2 -->|Markdown Report| Discord[📢 Discord Alert]
```

---

## 2. Components
The system consists of the following Docker services running in the `secops_net` network:

| Service | container_name | Role |
| :--- | :--- | :--- |
| **n8n** | `n8n-secops` | Workflow Orchestration & UI |
| **Kali Linux** | `kali-linux` | Attack Engine (SSH enabled) |
| **Juice Shop** | `juice-shop-victim` | **Victim 1** (Vulnerable Web App) |
| **Metasploitable**| `metasploitable-victim`| **Victim 2** (Vulnerable Linux OS) |
| **PostgreSQL** | `postgres-db` | n8n Database |
| **Tunnel** | `cloudflared-tunnel` | Secure Public Access |

---

## 3. Workflows
Found in `d:\dev\playground\lab-n8n-secops\workflows\`:

### A. Advanced SecOps AI Pipeline (`Advanced_SecOps_AI_Pipeline.json`)
The main workflow that handles the logic.
- **Trigger**: n8n Chat Interface
- **Orchestrator Agent**:
    - Role: Red Team Commander.
    - Capability: Validates input, selects tools, commands Kali to scan, aggregates results.
- **Reporter Agent**:
    - Role: Senior Analyst.
    - Capability: Converts raw JSON data into a professional Markdown Executive Report with Emoji indicators.

### B. Kali Executor Tool (`Kali_Executor_Tool.json`)
A sub-workflow acting as a "Tool" for the AI.
- **Function**: Receives a bash command string, executes it on Kali via SSH, and returns stdout/stderr.
- **Security**: Acts as an abstraction layer; the AI doesn't need to know SSH details, just the command to run.

---

## 4. Setup Instructions

### Step 1: Start the Environment
Run the following command in the project root:
```bash
docker-compose up -d
```

### Step 2: Configure n8n Credentials
1.  Open n8n (e.g., `https://n8n.your-domain.com`).
2.  Go to **Credentials** and add:
    *   **Google Gemini API**: For the AI Agents.
    *   **SSH Password**:
        *   **User**: `root`
        *   **Password**: `kali`
        *   **Host**: `kali-linux` (Use this exact hostname)
    *   **Discord Webhook**: Create a webhook in your Discord server channel.

### Step 3: Import Workflows
1.  Import `Kali_Executor_Tool.json` first.
    *   **Important**: Note its Workflow ID.
2.  Import `Advanced_SecOps_AI_Pipeline.json`.
3.  **Link the Tool**: Open the "Kali Executor Tool" node in the main pipeline and ensure the `Workflow ID` matches the one you just imported.

---

## 5. Usage Guide

### 🚀 Starting a Scan
1. Open the **Canvas** of `Advanced SecOps AI Pipeline`.
2. Click the **Chat** button (bottom right).
3. Type a command like:
    > "Scan the target juice-shop-victim and report any critical web vulnerabilities."
    > "Check metasploitable-victim for open ports and potential entry points."

### 📊 The Report
You will receive a notification in Discord containing:
*   **Executive Summary**: A high-level overview.
*   **Findings Table**: Top discovered issues.
*   **Remediation**: Suggested fixes.

### 🧪 Available Targets (Internal Hostnames)
*   `juice-shop-victim` (Port 3000)
*   `metasploitable-victim` (Ports 21, 22, 23, 80, etc.)
