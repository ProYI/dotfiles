#!/bin/bash
# Fedora 包名映射
# 逻辑包名 -> Fedora 实际包名

declare -gA PACKAGE_MAP=(
    # 基础工具
    ["build-tools"]="gcc make"

    # 网络
    ["ssh"]="openssh-server"

    # 实用工具
    ["fd"]="fd-find"

    # 字体
    ["cjk-font"]="google-noto-sans-cjk-fonts"
)

resolve_package() {
    echo "${PACKAGE_MAP[$1]:-$1}"
}
