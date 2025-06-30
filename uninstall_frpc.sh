#!/bin/bash

set -e

# ======= 1. 变量设置（需与安装脚本保持一致）=======
FRP_VERSION="0.63.0"
INSTALL_DIR="/root/frp"
SYSTEMD_SERVICE="/etc/systemd/system/frpc.service"

# ======= 2. 停止并禁用 frpc 服务 =======
echo "🛑 停止并禁用 frpc 服务..."
systemctl stop frpc || true
systemctl disable frpc || true

# ======= 3. 删除 systemd 配置文件 =======
if [ -f "$SYSTEMD_SERVICE" ]; then
    echo "🧹 删除 systemd 服务文件..."
    rm -f "$SYSTEMD_SERVICE"
    systemctl daemon-reload
fi

# ======= 4. 删除安装目录 =======
if [ -d "${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64" ]; then
    echo "🧹 删除安装目录 ${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64 ..."
    rm -rf "${INSTALL_DIR}/frp_${FRP_VERSION}_linux_amd64"
fi

if [ -f "${INSTALL_DIR}/frp.tar.gz" ]; then
    echo "🧹 删除压缩包 frp.tar.gz ..."
    rm -f "${INSTALL_DIR}/frp.tar.gz"
fi

# 如果整个 INSTALL_DIR 为空则删除
if [ -d "$INSTALL_DIR" ] && [ -z "$(ls -A $INSTALL_DIR)" ]; then
    echo "🧹 删除空的安装目录 $INSTALL_DIR ..."
    rmdir "$INSTALL_DIR"
fi

# ======= 5. 完成提示 =======
echo "✅ frpc 已成功卸载。"

