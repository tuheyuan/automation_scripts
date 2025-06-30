install_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        log "正在安装Docker..."
        
        # 检测系统并安装
        if [ -f /etc/debian_version ]; then
            apt-get update >> "$LOG_FILE" 2>&1
            apt-get install -y ca-certificates curl gnupg >> "$LOG_FILE" 2>&1
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg >> "$LOG_FILE" 2>&1
            chmod a+r /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update >> "$LOG_FILE" 2>&1
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> "$LOG_FILE" 2>&1 || {
                log "Docker安装失败"
                exit 1
            }
        elif [ -f /etc/redhat-release ]; then
            yum install -y yum-utils >> "$LOG_FILE" 2>&1
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >> "$LOG_FILE" 2>&1
            yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> "$LOG_FILE" 2>&1 || {
                log "Docker安装失败"
                exit 1
            }
        else
            log "不支持的Linux发行版"
            exit 1
        fi
        
        # 启动Docker
        systemctl start docker >> "$LOG_FILE" 2>&1
        systemctl enable docker >> "$LOG_FILE" 2>&1
        log "Docker安装完成"
        
        # 配置镜像加速
        configure_docker_mirrors
    else
        log "Docker已安装，跳过安装步骤"
        # 仍然配置镜像加速，确保已安装的Docker也有加速
        configure_docker_mirrors
    fi
}

install_docker()