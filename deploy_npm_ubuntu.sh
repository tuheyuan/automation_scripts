#!/bin/bash
# 自动化部署 Nginx Proxy Manager 脚本（适用于 Ubuntu）

set -e

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "未检测到 Docker，正在安装..."
    curl -fsSL https://get.docker.com | bash
    sudo usermod -aG docker $USER
    echo "Docker 安装完成，请重新登录终端以生效用户组权限。"
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "未检测到 Docker Compose，正在安装..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
fi

# 创建数据目录
mkdir -p ./data ./letsencrypt

# 生成 docker-compose.yml
cat > docker-compose.yml <<EOF
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

# 启动 Nginx Proxy Manager
if command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

echo "部署完成！请访问 http://<你的服务器IP>:81 进行管理。"
echo "默认账号：admin@example.com  默认密码：changeme"
