#!/bin/bash

# VLESS+WS Server Setup Script for Moldova (217.156.122.113)
# Run on Moldova server

set -e

echo "🚀 Setting up VLESS+WS Server on Moldova (217.156.122.113)"

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl wget unzip

# Create directories
sudo mkdir -p /etc/xray
sudo mkdir -p /var/log/xray

# Download latest Xray
LATEST_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d'"' -f4)
echo "📥 Downloading Xray $LATEST_VERSION..."
wget https://github.com/XTLS/Xray-core/releases/download/${LATEST_VERSION}/Xray-linux-64.zip
unzip -o Xray-linux-64.zip
sudo mv xray /usr/local/bin/
sudo chmod +x /usr/local/bin/xray
rm -rf Xray-linux-64.zip

# Generate UUID
UUID=$(xray uuid)
echo "✅ Generated UUID: $UUID"
echo "⚠️  Update the UUID in config-vless-ws.json with this value"

# Setup SSL Certificate (using self-signed or Let's Encrypt)
echo "📜 Generating self-signed certificate (for production use Let's Encrypt)"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/xray/key.key \
  -out /etc/xray/cert.crt \
  -subj "/CN=217.156.122.113" 2>/dev/null

sudo chown root:root /etc/xray
sudo chmod 755 /etc/xray

# Copy configuration
sudo cp config-vless-ws.json /etc/xray/config.json
sudo sed -i "s/YOUR-UUID-HERE/$UUID/g" /etc/xray/config.json
sudo chown root:root /etc/xray/config.json
sudo chmod 644 /etc/xray/config.json

# Create systemd service
sudo tee /etc/systemd/system/xray.service > /dev/null <<'EOF'
[Unit]
Description=Xray Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/xray
ExecStart=/usr/local/bin/xray -c /etc/xray/config.json
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable xray
sudo systemctl start xray

echo "✅ Server setup completed!"
echo "🔗 UUID for clients: $UUID"
echo "📊 Check logs: sudo journalctl -u xray -f"
