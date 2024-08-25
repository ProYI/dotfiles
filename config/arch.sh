#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

# 1. 设置系统语言
echo "Setting system language..."
sudo sed -i 's/#\(en_US.UTF-8\)/\1/' /etc/locale.gen
echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf
sudo locale-gen

# 2. 设置时区
echo "Setting timezone..."
sudo ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
sudo hwclock --systohc

# 3. 更新镜像地址
echo "Updating mirrorlist..."
sudo reflector --country Country --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

# 4. 更新系统
echo "Updating system..."
sudo pacman -Syu --noconfirm

# 链接.profile
if [ -f "$DOTFILES_DIR/.profile" ]; then
    ln -sf "$DOTFILES_DIR/.profile" "$HOME/.profile"
    echo ".profile 已链接到用户主目录！"
else
    echo "未找到 .profile 文件，跳过链接操作。"
fi

# 5. 安装常用软件包
echo "Installing essential packages..."
sudo pacman -S --needed --noconfirm vim zsh git

if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
else
    echo "未找到 .zshrc 文件，跳过链接操作。"
fi

PROFILE_FILE="$DOTFILES_DIR/.profile"
JAVA_PATH_ADDITION="export PATH=\$JAVA_HOME/bin:\$PATH"
# 6. 其他个性化设置

##### java ######
echo "Installing JDK21"
sudo pacman -S --noconfirm jdk21-openjdk
JAVA_HOME_PATH="export JAVA_HOME=/usr/lib/jvm/java-21-openjdk"
if ! grep -qF "$JAVA_HOME_PATH" "$PROFILE_FILE"; then
    echo "$JAVA_HOME_PATH" >> "$PROFILE_FILE"
    echo "Added JAVA_HOME to $PROFILE_FILE"
    
fi
if ! grep -qF "$JAVA_PATH_ADDITION" "$PROFILE_FILE"; then
    echo "$JAVA_PATH_ADDITION" >> "$PROFILE_FILE"
fi

##### java ######
echo "Installing Maven"
sudo pacman -S --noconfirm maven

M2_HOME="/usr/share/java/maven"
M2_BIN="$M2_HOME/bin"

M2_HOME_ADDITION="export M2_HOME=$M2_HOME"
M2_PATH_ADDITION="export PATH=\$M2_HOME/bin:\$PATH"

if ! grep -qF "$M2_HOME_ADDITION" "$PROFILE_FILE"; then
    echo "$M2_HOME_ADDITION" >> "$PROFILE_FILE"
    echo "Added M2_HOME to $PROFILE_FILE"
fi

if ! grep -qF "$M2_PATH_ADDITION" "$PROFILE_FILE"; then
    echo "$M2_PATH_ADDITION" >> "$PROFILE_FILE"
    echo "Added Maven bin to PATH in $PROFILE_FILE"
fi

echo "Arch Linux 配置完成！"