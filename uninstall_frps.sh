#!/bin/bash

set -e

SERVICE_NAME="frps"
INSTALL_DIR="/root/frp"

echo "🛑 正在停止并禁用 systemd 服务：${SERVICE_NAME}.service"

# 停止服务
systemctl stop ${SERVICE_NAME}.service || true

# 禁用服务
systemctl disable ${SERVICE_NAME}.service || true

# 删除 systemd 服务文件
if [ -f /etc/systemd/system/${SERVICE_NAME}.service ]; then
    rm -f /etc/systemd/system/${SERVICE_NAME}.service
    echo "✅ 已删除 /etc/systemd/system/${SERVICE_NAME}.service"
else
    echo "⚠️ 服务文件不存在，跳过删除"
fi

# 重新加载 systemd
systemctl daemon-reload
systemctl reset-failed

# 提示是否删除程序目录
echo -e "\n📁 当前 FRP 安装目录为：${INSTALL_DIR}"
read -p "是否删除整个安装目录？(y/n): " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
    rm -rf "${INSTALL_DIR}"
    echo "✅ 已删除安装目录：${INSTALL_DIR}"
else
    echo "ℹ️ 安装目录保留：${INSTALL_DIR}"
fi

echo -e "\n✅ frps 卸载完成！"

