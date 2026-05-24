FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Xray
RUN mkdir -p /etc/xray /var/log/xray && \
    LATEST_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep -oP '"tag_name": "\K[^"]*') && \
    wget -q https://github.com/XTLS/Xray-core/releases/download/${LATEST_VERSION}/Xray-linux-64.zip -O /tmp/xray.zip && \
    unzip /tmp/xray.zip -d /tmp/ && \
    mv /tmp/xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip

# Copy configurations
COPY config-vless-ws.json /etc/xray/config.json

# Generate self-signed certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/xray/key.key \
    -out /etc/xray/cert.crt \
    -subj "/CN=tunnel-relay"

# Expose port
EXPOSE 443

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD xray -c /etc/xray/config.json -version

# Run Xray
CMD ["/usr/local/bin/xray", "-c", "/etc/xray/config.json"]
