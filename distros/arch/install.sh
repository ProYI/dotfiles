#!/bin/bash
# Arch Linux 安装脚本

DOTFILES_DIR="$HOME/.dotfiles"

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

# 5. 从 packages.txt 安装软件包（通过包名映射）
if [ -f "$DOTFILES_DIR/distros/arch/packages-map.sh" ]; then
    source "$DOTFILES_DIR/distros/arch/packages-map.sh"
fi

if [ -f "$DOTFILES_DIR/distros/arch/packages.txt" ]; then
    echo "Installing packages from packages.txt..."
    packages=()
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        pkg=$(resolve_package "$line")
        packages+=($pkg)
    done < "$DOTFILES_DIR/distros/arch/packages.txt"

    if [ ${#packages[@]} -gt 0 ]; then
        sudo pacman -S --needed --noconfirm "${packages[@]}"
    fi
fi

echo "Arch Linux 配置完成！"
