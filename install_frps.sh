#!/bin/bash

set -e

# 1. 配置参数
FRP_VERSION="0.63.0"
INSTALL_DIR="/root/frp"
FRP_PORT=57000
FRP_DASHBOARD_PORT=57001
FRP_USER="admin"
FRP_PASSWORD="admin123"

# 生成20位随机Token
FRP_TOKEN=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)

# 2. 判断是否为国内网络（无法访问 google 则视为国内）
echo "🌐 检查是否处于中国大陆网络..."
if ping -c 1 -W 1 www.google.com > /dev/null 2>&1; then
    echo "✅ 网络正常，使用 GitHub 官方地址下载"
    DOWNLOAD_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
else
    echo "🇨🇳 检测为国内网络，使用加速镜像下载"
    DOWNLOAD_URL="https://gh-proxy.com/https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
fi

# 3. 创建安装目录
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# 4. 下载并解压
echo "⬇️ 下载 FRP ${FRP_VERSION} ..."
wget -q --show-progress "$DOWNLOAD_URL" -O frp.tar.gz
tar -xvzf frp.tar.gz
cd frp_${FRP_VERSION}_linux_amd64

# 5. 创建配置文件 frps.toml
cat > frps.toml <<EOF
bindPort = ${FRP_PORT}

webServer.addr = "0.0.0.0"
webServer.port = ${FRP_DASHBOARD_PORT}
webServer.user = "${FRP_USER}"
webServer.password = "${FRP_PASSWORD}"

auth.token = "${FRP_TOKEN}"

log.to = "./log"
log.level = "info"
log.maxDays = 7
EOF

# 6. 校验配置
./frps verify -c ./frps.toml

# 7. 创建 systemd 服务
cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64
ExecStart=${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64/frps -c ${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64/frps.toml
Restart=on-failure
RestartSec=5s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 8. 启动服务并设置自启
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable frps
systemctl restart frps

# 9. 显示状态
systemctl status frps --no-pager

# 10. 输出配置
echo -e "\n✅ FRPS 安装并启动成功！"
echo "📁 配置文件内容（配置文件位置: ${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64/frps.toml）："
echo "---------------------------------"
cat frps.toml
echo "---------------------------------"
echo "📌 安装路径：${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64"
echo "🔐 生成的Token：${FRP_TOKEN}"

