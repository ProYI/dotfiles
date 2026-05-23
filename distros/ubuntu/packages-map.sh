#!/bin/bash
# Ubuntu 包名映射
# 逻辑包名 -> Ubuntu 实际包名

declare -A PACKAGE_MAP=(
    # 基础工具
    ["build-tools"]="build-essential"

    # 网络
    ["ssh"]="openssh-server"

    # 实用工具
    ["fd"]="fd-find"

    # 浏览器
    ["chromium"]="chromium-browser"

    # 字体
    ["nerd-font-jetbrains-mono"]="fonts-jetbrains-mono-nerd"
    ["cjk-font"]="fonts-noto-cjk"
)

resolve_package() {
    echo "${PACKAGE_MAP[$1]:-$1}"
}
