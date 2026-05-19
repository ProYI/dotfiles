#!/bin/bash
# Ubuntu 安装脚本

DOTFILES_DIR="$HOME/.dotfiles"

echo "开始 Ubuntu 系统配置..."

# 更新系统
echo "更新系统..."
sudo apt update && sudo apt upgrade -y

# 从 packages.txt 安装软件包
if [ -f "$DOTFILES_DIR/distros/ubuntu/packages.txt" ]; then
    echo "安装软件包..."
    while IFS= read -r package; do
        # 跳过注释和空行
        [[ "$package" =~ ^#.*$ ]] && continue
        [[ -z "$package" ]] && continue

        echo "安装 $package..."
        sudo apt install -y "$package"
    done < "$DOTFILES_DIR/distros/ubuntu/packages.txt"
fi

echo "Ubuntu 配置完成！"
