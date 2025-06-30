#!/bin/bash

# 设置变量
MINICONDA_INSTALLER=Miniconda3-latest-Linux-x86_64.sh
MINICONDA_URL=https://mirror.nyist.edu.cn/anaconda/miniconda/$MINICONDA_INSTALLER
# MINICONDA_URL=https://mirrors.ustc.edu.cn/anaconda/miniconda/$MINICONDA_INSTALLER
ENV_NAME=autogen_env
PYTHON_VERSION=3.11

# 检查安装包是否已存在
if [ ! -f "$MINICONDA_INSTALLER" ]; then
    # 下载 Miniconda 安装脚本
    echo "Downloading Miniconda installer..."
    wget $MINICONDA_URL -O $MINICONDA_INSTALLER
else
    echo "Miniconda installer already exists, skipping download..."
fi

# 安装 Miniconda
echo "Installing Miniconda..."
bash $MINICONDA_INSTALLER -b -p $HOME/miniconda

# 初始化 Conda
echo "Initializing Conda..."
$HOME/miniconda/bin/conda init bash
source ~/.bashrc

# 配置 Conda 使用 USTC 镜像源
echo "Configuring Conda to use USTC mirror..."
cat >~/.condarc <<EOL
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/main
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/r
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.ustc.edu.cn/anaconda/cloud
  bioconda: https://mirrors.ustc.edu.cn/anaconda/cloud
EOL

# 清理 Conda 缓存
echo "Cleaning Conda cache..."
conda clean -i -y

# 创建并激活 Python 3.11 虚拟环境
echo "Creating and activating Python $PYTHON_VERSION environment..."
conda create -n $ENV_NAME python=$PYTHON_VERSION -y
conda activate $ENV_NAME

# # 安装 AutoGen Studio
# echo "Installing AutoGen Studio..."
# pip uninstall autogenstudio -y # 卸载旧版本
# pip install autogenstudio -i https://mirrors.aliyun.com/pypi/simple
# pip install autogenstudio -i https://pypi.tuna.tsinghua.edu.cn/simple/
# pip install autogenstudio -i https://mirrors.huaweicloud.com/repository/pypi/simple/
# pip install autogenstudio -i https://mirrors.cloud.tencent.com/pypi/simple/
pip install autogenstudio -i https://pypi.mirrors.ustc.edu.cn/simple/

# # 启动 AutoGen Studio 在 8080 端口
# echo "Starting AutoGen Studio on port 8080..."
# autogenstudio ui --host 0.0.0.0 --port 8080