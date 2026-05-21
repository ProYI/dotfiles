#!/bin/bash
# Python3 安装脚本

set -euo pipefail

MODULE_NAME="python"

log_info() {
    echo -e "\033[0;34m==>\033[0m [${MODULE_NAME}] $1"
}

log_success() {
    echo -e "\033[0;32m✓\033[0m [${MODULE_NAME}] $1"
}

log_warning() {
    echo -e "\033[1;33m⚠\033[0m [${MODULE_NAME}] $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

install_python3() {
    if command_exists python3; then
        log_success "Python3 已安装 (版本: $(python3 --version 2>/dev/null | head -1))"
        return 0
    fi

    log_info "安装 Python3..."

    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip python3-venv
    elif command_exists dnf; then
        sudo dnf install -y python3 python3-pip
    elif command_exists pacman; then
        sudo pacman -S --needed --noconfirm python python-pip
    elif command_exists brew; then
        brew install python
    else
        log_warning "未找到支持的包管理器，无法自动安装 Python3"
        return 1
    fi

    if command_exists python3; then
        log_success "Python3 安装完成 (版本: $(python3 --version 2>/dev/null | head -1))"
        return 0
    fi

    log_warning "Python3 安装可能失败，请检查输出"
    return 1
}

install_python3
