#!/bin/bash
# Arch Linux 特定配置

# Arch 特定别名
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias cleanup='sudo pacman -Sc && sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null'

# AUR 助手（如果安装了 yay 或 paru）
if command -v yay &> /dev/null; then
    alias aur='yay'
    alias aurupdate='yay -Syu'
elif command -v paru &> /dev/null; then
    alias aur='paru'
    alias aurupdate='paru -Syu'
fi

# Pacman 镜像
alias mirror='sudo reflector --country China --latest 10 --sort rate --save /etc/pacman.d/mirrorlist'

echo "Arch Linux 配置已加载"
