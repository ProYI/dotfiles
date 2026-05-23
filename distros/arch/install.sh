#!/bin/bash
# Arch Linux 安装脚本

log_warning() {
    echo -e "\033[1;33m⚠${NC} 跳过: $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# 检测包是否已安装（pacman）
pkg_installed() {
    pacman -Qi "$1" &> /dev/null
}

# 检测包是否已安装（aurhelper）
aurpkg_installed() {
    local pkg="$1"
    if command -v yay &> /dev/null; then
        yay -Qi "$pkg" &> /dev/null
    elif command -v paru &> /dev/null; then
        paru -Qi "$pkg" &> /dev/null
    else
        return 1
    fi
}

# 检查逻辑包名是否被用户选中
is_package_selected() {
    local pkg_name="$1"
    local selected="${DOTFILES_SELECTED_PACKAGES:-}"
    local IFS=','
    for p in $selected; do
        [[ "$p" == "$pkg_name" ]] && return 0
    done
    return 1
}

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

# 5. 从 packages-map 解析包名映射
if [ -f "$DOTFILES_DIR/distros/arch/packages-map.sh" ]; then
    source "$DOTFILES_DIR/distros/arch/packages-map.sh"
fi

# 6. 从 packages.txt 安装软件包
if [ -f "$DOTFILES_DIR/distros/arch/packages.txt" ]; then
    echo "安装软件包..."
    packages=()
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        if ! is_package_selected "$line"; then
            log_warning "跳过 $line（未选择）"
            continue
        fi

        if pkg_installed "$line"; then
            log_warning "检测到已有 $line，不重新安装"
            continue
        fi

        if ! pkg_installed "$line" && aurpkg_installed "$line"; then
            log_warning "检测到已有 $line（AUR），不重新安装"
            continue
        fi

        pkg=$(resolve_package "$line")
        packages+=($pkg)
    done < "$DOTFILES_DIR/distros/arch/packages.txt"

    if [ ${#packages[@]} -gt 0 ]; then
        sudo pacman -S --needed --noconfirm "${packages[@]}" || true
    fi
fi

echo "Arch Linux 配置完成！"
