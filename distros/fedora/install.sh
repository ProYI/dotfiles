#!/bin/bash
# Fedora 安装脚本

DOTFILES_DIR="$HOME/.dotfiles"

echo "开始 Fedora 系统配置..."

# 更新系统
echo "更新系统..."
sudo dnf upgrade -y

# 从 packages.txt 安装软件包（通过包名映射）
if [ -f "$DOTFILES_DIR/distros/fedora/packages-map.sh" ]; then
    source "$DOTFILES_DIR/distros/fedora/packages-map.sh"
fi

if [ -f "$DOTFILES_DIR/distros/fedora/packages.txt" ]; then
    echo "安装软件包..."
    packages=()
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        pkg=$(resolve_package "$line")
        packages+=($pkg)
    done < "$DOTFILES_DIR/distros/fedora/packages.txt"

    if [ ${#packages[@]} -gt 0 ]; then
        sudo dnf install -y "${packages[@]}"
    fi
fi

echo "Fedora 配置完成！"
