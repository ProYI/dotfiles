#!/bin/bash
# Debian 安装脚本

DISTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$DISTRO_DIR/../.." && pwd)}"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/package-manager.sh"

echo "开始 Debian 系统配置..."

# 刷新包索引。完整系统升级可能阻塞或失败，不能放在所选包安装前。
echo "更新软件包索引..."
sudo apt update

dotfiles_install_selected_packages "debian" "apt"

echo "Debian 配置完成！"
