#!/bin/bash
# Ubuntu 安装脚本

DOTFILES_DIR="$HOME/.dotfiles"

log_warning() {
    echo -e "\033[1;33m⚠${NC} 跳过: $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# 检测包是否已安装（dpkg）
pkg_installed() {
    dpkg -l "$1" &> /dev/null
}

echo "开始 Ubuntu 系统配置..."

# 更新系统
echo "更新系统..."
sudo apt update && sudo apt upgrade -y

# 从 packages.txt 安装软件包（通过包名映射）
if [ -f "$DOTFILES_DIR/distros/ubuntu/packages-map.sh" ]; then
    source "$DOTFILES_DIR/distros/ubuntu/packages-map.sh"
fi

if [ -f "$DOTFILES_DIR/distros/ubuntu/packages.txt" ]; then
    echo "安装软件包..."
    packages=()
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # 检查是否已安装
        if pkg_installed "$line"; then
            log_warning "检测到已有 $line，不重新安装"
            continue
        fi

        pkg=$(resolve_package "$line")
        packages+=($pkg)
    done < "$DOTFILES_DIR/distros/ubuntu/packages.txt"

    if [ ${#packages[@]} -gt 0 ]; then
        sudo apt install -y "${packages[@]}" || true
    fi
fi

echo "Ubuntu 配置完成！"
