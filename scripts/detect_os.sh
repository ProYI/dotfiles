#!/bin/bash
# 系统检测脚本

detect_os() {
    # 检测操作系统类型
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "$ID"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

detect_wsl() {
    # 检测是否在 WSL 中运行
    if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    OS=$(detect_os)
    echo "操作系统: $OS"

    if detect_wsl; then
        echo "运行环境: WSL"
    fi
fi
