#!/bin/bash
# Arch Linux 安装脚本

DISTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$DISTRO_DIR/../.." && pwd)}"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/package-manager.sh"

echo "开始 Arch Linux 系统配置..."

# 1. 设置系统语言
echo "Setting system language..."
sudo sed -i 's/#\(en_US.UTF-8\)/\1/' /etc/locale.gen
echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf
sudo locale-gen

# 2. 设置时区
echo "Setting timezone..."
sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
sudo hwclock --systohc

# 3. 更新镜像地址
echo "Updating mirrorlist..."
sudo reflector --country China --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# 4. 更新系统
echo "Updating system..."
sudo pacman -Syu --noconfirm

# 5. 安装选择的软件包
dotfiles_install_selected_packages "arch" "pacman"

echo "Arch Linux 配置完成！"
