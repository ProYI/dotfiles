#!/bin/bash
# Debian 安装脚本

DOTFILES_DIR="$HOME/.dotfiles"

echo "开始 Debian 系统配置..."

# 更新系统
echo "更新系统..."
sudo apt update && sudo apt upgrade -y

# 从 packages.txt 安装软件包（通过包名映射）
if [ -f "$DOTFILES_DIR/distros/debian/packages-map.sh" ]; then
    source "$DOTFILES_DIR/distros/debian/packages-map.sh"
fi

if [ -f "$DOTFILES_DIR/distros/debian/packages.txt" ]; then
    echo "安装软件包..."
    packages=()
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        pkg=$(resolve_package "$line")
        packages+=($pkg)
    done < "$DOTFILES_DIR/distros/debian/packages.txt"

    if [ ${#packages[@]} -gt 0 ]; then
        sudo apt install -y "${packages[@]}"
    fi
fi

echo "Debian 配置完成！"
