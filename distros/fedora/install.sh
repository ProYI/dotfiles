#!/bin/bash
# Fedora 安装脚本

DISTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$DISTRO_DIR/../.." && pwd)}"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/package-manager.sh"

echo "开始 Fedora 系统配置..."

# 更新系统
echo "更新系统..."
sudo dnf upgrade -y

dotfiles_install_selected_packages "fedora" "dnf"

echo "Fedora 配置完成！"
