#!/bin/bash
# Fedora 安装脚本

log_warning() {
    echo -e "\033[1;33m⚠${NC} 跳过: $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# 检测包是否已安装（rpm/dnf）
pkg_installed() {
    rpm -qi "$1" &> /dev/null
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

echo "开始 Fedora 系统配置..."

# 更新系统
echo "更新系统..."
sudo dnf upgrade -y

# 从 packages-map 解析包名映射
if [ -f "$DOTFILES_DIR/distros/fedora/packages-map.sh" ]; then
    source "$DOTFILES_DIR/distros/fedora/packages-map.sh"
fi

# 从 packages.txt 安装软件包
if [ -f "$DOTFILES_DIR/distros/fedora/packages.txt" ]; then
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

        pkg=$(resolve_package "$line")
        packages+=($pkg)
    done < "$DOTFILES_DIR/distros/fedora/packages.txt"

    if [ ${#packages[@]} -gt 0 ]; then
        sudo dnf install -y "${packages[@]}" || true
    fi
fi

echo "Fedora 配置完成！"
