# Tunnel Relay - VLESS+WS VPN

تونل امن بین سرور ایران و مولداوی با استفاده از VLESS+WebSocket

## 🌐 Network Architecture

```
Iran Client (85.9.124.94)
    ↓ VLESS+WS
    ↓ (WebSocket + TLS)
    ↓
Moldova Server (217.156.122.113)
    ↓
    ↓ (Freedom - Any destination)
    ↓
Internet
```

## 📋 Prerequisites

### سرور مولداوی (217.156.122.113):
- Ubuntu 20.04 یا بالاتر
- 1GB RAM (minimum)
- دسترسی sudo
- درگاه 443 باز

### کلاینت ایران (85.9.124.94):
- Ubuntu 20.04 یا بالاتر
- دسترسی sudo

## 🚀 Installation

### Step 1: Clone Configuration Files

```bash
git clone https://github.com/arsalaneslami31-wq/tunnel-relay.git
cd tunnel-relay
```

### Step 2: Server Setup (Moldova - 217.156.122.113)

```bash
chmod +x setup-server.sh
sudo ./setup-server.sh
```

**مراحل:**
1. اسکریپت خودکار UUID تولید می‌کند
2. SSL Certificate self-signed ایجاد می‌کند
3. Xray Service راه‌اندازی می‌کند

**خروجی:** UUID برای کلاینت

### Step 3: Update Configuration

سرور UUID را از مرحله 2 کپی کنید و در فایل‌های زیر قرار دهید:

```bash
# روی سرور
sudo nano /etc/xray/config.json
# UUID را جایگزین کنید

# روی کلاینت
nano client-config.json
# UUID را جایگزین کنید
```

### Step 4: Client Setup (Iran - 85.9.124.94)

```bash
chmod +x setup-client.sh
sudo ./setup-client.sh
```

## ✅ Verification

### سرور را تست کنید:
```bash
sudo systemctl status xray
sudo journalctl -u xray -f
```

### کلاینت را تست کنید:
```bash
sudo systemctl status xray
sudo journalctl -u xray -f

# Test proxy
curl -x socks5://127.0.0.1:10808 https://www.google.com
```

## 🔧 Configuration Files

| فایل | توضیح |
|------|-------|
| `config-vless-ws.json` | تنظیمات سرور VLESS+WS |
| `client-config.json` | تنظیمات کلاینت SOCKS5 |
| `setup-server.sh` | اسکریپت نصب سرور |
| `setup-client.sh` | اسکریپت نصب کلاینت |

## 🔐 Security Notes

⚠️ **SSL Certificate:**
- فعلاً self-signed certificate استفاده می‌شود
- برای production: از Let's Encrypt استفاده کنید

```bash
sudo certbot certonly --standalone -d your-domain.com
```

## 📊 Monitoring

### Logs بررسی کنید:
```bash
# سرور
sudo journalctl -u xray -f

# کلاینت
sudo journalctl -u xray -f
```

### Traffic monitoring:
```bash
ss -tulpn | grep xray
netstat -an | grep 443
```

## 🛠️ Troubleshooting

### Connection Refused
```bash
sudo ufw allow 443
sudo ufw allow 10808
```

### TLS Handshake Failed
```bash
# سرور: Certificate را بررسی کنید
ls -la /etc/xray/cert.crt /etc/xray/key.key

# کلاینت: Firewall بررسی کنید
sudo ufw status
```

### UUID Mismatch
```bash
# UUID را بدست آورید
xray uuid

# هر دو config را update کنید
```

## 📱 Usage Examples

### Firefox/Chrome (FoxyProxy):
1. Install FoxyProxy
2. Add Proxy: `SOCKS5 127.0.0.1 10808`
3. Enable proxy

### Command Line:
```bash
export http_proxy=socks5://127.0.0.1:10808
export https_proxy=socks5://127.0.0.1:10808
curl https://www.example.com
```

### SSH Through Proxy:
```bash
ssh -o ProxyCommand="nc -X 5 -x 127.0.0.1:10808 %h %p" user@remote-host
```

## 📈 Performance

**تست سرعت:**
```bash
# iperf3 بر روی سرور
iperf3 -s -p 5201

# iperf3 بر روی کلاینت
iperf3 -c 127.0.0.1 -p 5201
```

## ⚙️ Advanced Configuration

### تغییر درگاه:
```json
"port": 8443,  // بجای 443
```

### چندین کلاینت:
```json
"clients": [
  {"id": "UUID-1", "alterId": 0},
  {"id": "UUID-2", "alterId": 0}
]
```

### Fallback Domain:
```json
"wsSettings": {
  "path": "/tunnel",
  "headers": {
    "Host": "example.com"
  }
}
```

## 📞 Support

برای مسائل و سوالات:
1. Logs را بررسی کنید
2. Issue ایجاد کنید
3. Configuration را double-check کنید

---

**Created:** May 24, 2026
**Status:** Active
**Protocol:** VLESS + WebSocket + TLS
