#!/bin/bash
# Ubuntu 安装脚本

log_warning() {
    echo -e "\033[1;33m⚠${NC} 跳过: $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# 检测实际包是否已安装（dpkg）
pkg_installed() {
    dpkg -s "$1" &> /dev/null
}

# 检测实际包是否可从当前 apt 源安装
pkg_available() {
    apt-cache show "$1" &> /dev/null
}

load_packages_to_install() {
    if [ -n "${DOTFILES_SELECTED_PACKAGES:-}" ]; then
        local IFS=','
        for pkg_name in $DOTFILES_SELECTED_PACKAGES; do
            [ -n "$pkg_name" ] && echo "$pkg_name"
        done
        return
    fi

    if [ -f "$DOTFILES_DIR/distros/ubuntu/packages.txt" ]; then
        while IFS= read -r line; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            echo "$line"
        done < "$DOTFILES_DIR/distros/ubuntu/packages.txt"
    fi
}

echo "开始 Ubuntu 系统配置..."

# 刷新包索引。完整系统升级可能阻塞或失败，不能放在所选包安装前。
echo "更新软件包索引..."
sudo apt update

# 从 packages-map 解析包名映射
if [ -f "$DOTFILES_DIR/distros/ubuntu/packages-map.sh" ]; then
    source "$DOTFILES_DIR/distros/ubuntu/packages-map.sh"
fi

# 安装软件包。交互式安装以 DOTFILES_SELECTED_PACKAGES 为准，单独运行脚本时回退到 packages.txt。
echo "安装软件包..."
packages=()
while IFS= read -r line; do
    pkg=$(resolve_package "$line")
    for actual_pkg in $pkg; do
        if pkg_installed "$actual_pkg"; then
            log_warning "检测到已有 $line ($actual_pkg)，不重新安装"
            continue
        fi

        if ! pkg_available "$actual_pkg"; then
            log_warning "$line ($actual_pkg) 不在当前 apt 源中，无法安装"
            continue
        fi

        packages+=("$actual_pkg")
    done
done < <(load_packages_to_install)

if [ ${#packages[@]} -gt 0 ]; then
    sudo apt install -y "${packages[@]}" || true
fi

echo "Ubuntu 配置完成！"
