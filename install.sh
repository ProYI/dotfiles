#!/bin/bash

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
elif [ "$(uname)" == "Darwin" ]; then
    OS="macos"
else
    echo "无法检测操作系统。"
    exit 1
fi

# 根据操作系统进行不同的配置
case "$OS" in
    ubuntu)
        echo "检测到 Ubuntu，正在应用 Ubuntu 配置..."
        # Ubuntu 的配置命令
        ;;
    debian)
        echo "检测到 Debian，正在应用 Debian 配置..."
        # Debian 的配置命令
        ;;
    arch)
        echo "检测到 Arch Linux，正在应用 Arch 配置..."
        # Arch Linux 的配置命令
        source ./config/arch.sh
        ;;
    fedora)
        echo "检测到 Fedora，正在应用 Fedora 配置..."
        # Fedora 的配置命令
        ;;
    macos)
        echo "检测到 macOS，正在应用 macOS 配置..."
        # macOS 的配置命令
        ;;
    *)
        echo "未知的操作系统：$OS，跳过特定配置。"
        ;;
esac

# 根据操作系统进行不同的配置
case "$OS" in
    ubuntu|debian|arch|fedora)
        echo "Linux 配置 软链接..."
        ln -sf "$(pwd)/.vimrc" "$HOME/.vimrc"
        
        echo "Vim 配置已应用！"
        ;;
    macos)
        echo "macOS 配置 软链接..."
        ln -sf "$(pwd)/.vimrc" "$HOME/.vimrc"

        echo "Vim 配置已应用！"
        ;;
    *)
        echo "未知的操作系统：$OS，跳过特定配置。"
        ;;
esac

echo "配置完成！"