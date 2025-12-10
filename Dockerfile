FROM n8nio/n8n:latest

USER root

# 1. ติดตั้ง Basic Tools
RUN apk add --no-cache curl nmap bind-tools bash jq

# 2. ติดตั้ง Nuclei (Manual Install - ARM64 Version for Snapdragon)
RUN curl -L -o nuclei.zip https://github.com/projectdiscovery/nuclei/releases/download/v3.2.9/nuclei_3.2.9_linux_arm64.zip && \
    unzip nuclei.zip && \
    mv nuclei /usr/local/bin/ && \
    chmod +x /usr/local/bin/nuclei && \
    rm nuclei.zip

# 3. สร้างโฟลเดอร์ Template
RUN mkdir -p /home/node/nuclei-templates && \
    chown -R node:node /home/node/nuclei-templates

USER node