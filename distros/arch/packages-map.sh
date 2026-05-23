#!/bin/bash
# Arch Linux 包名映射
# 逻辑包名 -> Arch 实际包名

declare -gA PACKAGE_MAP=(
    # 基础工具
    ["build-tools"]="base-devel"

    # 网络
    ["ssh"]="openssh"

    # 实用工具
    ["fd"]="fd"

    # 字体
    ["cjk-font"]="noto-fonts-cjk"
)

resolve_package() {
    echo "${PACKAGE_MAP[$1]:-$1}"
}
