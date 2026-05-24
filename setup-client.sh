#!/bin/bash

# VLESS+WS Client Setup Script for Iran (85.9.124.94)
# Run on Iran client machine

set -e

echo "🚀 Setting up VLESS+WS Client on Iran (85.9.124.94)"

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

# Copy configuration
sudo cp client-config.json /etc/xray/config.json
sudo chown root:root /etc/xray/config.json
sudo chmod 644 /etc/xray/config.json

# Create systemd service
sudo tee /etc/systemd/system/xray.service > /dev/null <<'EOF'
[Unit]
Description=Xray Client Service
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

echo "✅ Client setup completed!"
echo "📡 SOCKS5 proxy available at: 127.0.0.1:10808"
echo "📊 Check logs: sudo journalctl -u xray -f"
echo ""
echo "🔗 To use the proxy:"
echo "   - FoxyProxy: Add SOCKS5 127.0.0.1:10808"
echo "   - CLI: export http_proxy=socks5://127.0.0.1:10808"
