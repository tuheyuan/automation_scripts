#!/bin/bash

set -e

# ======= 1. 参数配置 =======
FRP_VERSION="0.63.0"
INSTALL_DIR="/root/frp"
SERVER_ADDR="156.227.233.223"
SERVER_PORT=57000
AUTH_TOKEN="b652ecc32bb9"
LOCAL_IP="127.0.0.1"
LOCAL_PORT=22
REMOTE_PORT=57002
PROXY_NAME="test-tcp"

# ======= 2. 检查网络位置 =======
echo "🌐 检查是否处于中国大陆网络..."
if ping -c 1 -W 1 www.google.com > /dev/null 2>&1; then
    echo "✅ 网络正常，使用 GitHub 官方源"
    DOWNLOAD_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
else
    echo "🇨🇳 检测为中国大陆网络，使用加速镜像"
    DOWNLOAD_URL="https://gh-proxy.com/https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
fi

# ======= 3. 下载并解压 =======
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}
wget -q --show-progress "$DOWNLOAD_URL" -O frp.tar.gz
tar -xvzf frp.tar.gz
cd frp_${FRP_VERSION}_linux_amd64

# ======= 4. 创建 frpc.toml =======
cat > frpc.toml <<EOF
serverAddr = "${SERVER_ADDR}"
serverPort = ${SERVER_PORT}
auth.token = "${AUTH_TOKEN}"

[[proxies]]
name = "${PROXY_NAME}"
type = "tcp"
localIP = "${LOCAL_IP}"
localPort = ${LOCAL_PORT}
remotePort = ${REMOTE_PORT}
EOF

# ======= 5. 创建 systemd 服务 =======
cat > /etc/systemd/system/frpc.service <<EOF
[Unit]
Description=Frp Client Service
After=network.target

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64
ExecStart=${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64/frpc -c ${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64/frpc.toml
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# ======= 6. 启动并设置自启 =======
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable frpc
systemctl restart frpc

# ======= 7. 显示状态 =======
echo -e "\n📈 当前 frpc 服务状态："
systemctl status frpc --no-pager || true

# ======= 8. 输出配置文件内容 =======
echo -e "\n✅ frpc 安装并启动成功！"
echo "📁 配置文件内容（配置文件位置: ${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64/frpc.toml）："
echo "--------------------------------------------------"
cat frpc.toml
echo "--------------------------------------------------"

