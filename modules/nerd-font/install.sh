#!/bin/bash
# JetBrainsMono Nerd Font 安装脚本：使用 Nerd Fonts 上游 release，避免发行版包名差异。

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="nerd-font"
FONT_NAME="JetBrainsMono Nerd Font"
FONT_ARCHIVE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

# shellcheck disable=SC1091
source "$MODULE_DIR/../../scripts/lib/module.sh"
# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/proxy.sh"

font_installed() {
    command_exists fc-list && fc-list : family | grep -qi "$FONT_NAME"
}

install_deps() {
    if command_exists fc-list && { command_exists curl || command_exists wget; }; then
        return 0
    fi

    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y fontconfig curl xz-utils
        return 0
    fi

    if command_exists dnf; then
        sudo dnf install -y fontconfig curl xz
        return 0
    fi

    if command_exists pacman; then
        sudo pacman -S --needed --noconfirm fontconfig curl xz
        return 0
    fi

    return 0
}

download_archive() {
    local archive="$1"

    if command_exists curl; then
        curl -fL "$FONT_ARCHIVE_URL" -o "$archive"
        return
    fi

    if command_exists wget; then
        wget -O "$archive" "$FONT_ARCHIVE_URL"
        return
    fi

    return 1
}

font_dir() {
    if [[ "${OSTYPE:-}" == darwin* ]]; then
        echo "$HOME/Library/Fonts/JetBrainsMonoNerdFont"
    else
        echo "${XDG_DATA_HOME:-$HOME/.local/share}/fonts/JetBrainsMonoNerdFont"
    fi
}

refresh_font_cache() {
    local target_dir="$1"

    if command_exists fc-cache; then
        fc-cache -f "$target_dir" >/dev/null
    fi
}

font_files_exist() {
    local target_dir="$1"

    [ -d "$target_dir" ] || return 1
    find "$target_dir" -type f \( -name '*.ttf' -o -name '*.otf' \) | grep -q .
}

if font_installed; then
    log_success "$FONT_NAME 已安装"
    exit 0
fi

install_deps

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

archive="$tmp_dir/JetBrainsMono.tar.xz"
target_dir="$(font_dir)"

if font_files_exist "$target_dir"; then
    log_info "检测到已有字体文件，刷新 fontconfig 缓存..."
    refresh_font_cache "$target_dir"
    if font_installed; then
        log_success "$FONT_NAME 安装完成"
        exit 0
    fi
fi

log_info "下载 $FONT_NAME..."
setup_proxy_env
download_archive "$archive"

mkdir -p "$target_dir"
tar -xJf "$archive" -C "$target_dir"
refresh_font_cache "$target_dir"

if font_installed; then
    log_success "$FONT_NAME 安装完成"
else
    log_warning "$FONT_NAME 已解压到 $target_dir，但 fontconfig 尚未检测到"
fi
