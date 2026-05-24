#!/bin/bash

# VLESS+WS Client Setup Script for Iran (85.9.124.94)
# Run on Iran client machine
# Xray must be already installed at /usr/local/bin/xray

set -e

echo "🚀 Setting up VLESS+WS Client Configuration"

# Create directories
sudo mkdir -p /etc/xray
sudo mkdir -p /var/log/xray

# Verify Xray is installed
if [ ! -f /usr/local/bin/xray ]; then
    echo "❌ Error: Xray not found at /usr/local/bin/xray"
    echo "Please install Xray first"
    exit 1
fi

echo "✅ Xray found: $(/usr/local/bin/xray -version | head -1)"

# Copy configuration
echo "📋 Copying client configuration..."
sudo cp client-config.json /etc/xray/config.json
sudo chown root:root /etc/xray/config.json
sudo chmod 644 /etc/xray/config.json

# Create systemd service
echo "🔧 Creating systemd service..."
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
echo ""
echo "🔗 Testing connection:"
echo "   curl -x socks5://127.0.0.1:10808 http://example.com"
echo ""
echo "📊 Check logs:"
echo "   sudo journalctl -u xray -f"
echo ""
echo "🔍 Check status:"
echo "   sudo systemctl status xray"
