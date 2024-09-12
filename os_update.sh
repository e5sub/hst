#!/bin/bash
# 检测操作系统类型
if [ -f /etc/redhat-release ]; then
    # CentOS 或其他基于Red Hat的系统
    echo "检测到系统为类Red Hat系统"
    echo "执行 yum 更新..."
    yum -y update
elif [ -f /etc/lsb-release ]; then
    # Ubuntu 或 Debian 系统
    echo "检测到系统为类debian系统"
    echo "执行 apt 更新..."
    apt update && apt upgrade -y
else
    echo "未知操作系统，无法确定更新命令。"
    exit 1
fi