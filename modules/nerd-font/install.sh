#!/bin/bash
# JetBrainsMono Nerd Font 安装脚本：使用 Nerd Fonts 上游 release，避免发行版包名差异。

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="nerd-font"
FONT_NAME="JetBrainsMono Nerd Font"
FONT_ARCHIVE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

log_info() {
    echo -e "\033[0;34m==>\033[0m [${MODULE_NAME}] $1"
}

log_success() {
    echo -e "\033[0;32m✓\033[0m [${MODULE_NAME}] $1"
}

log_warning() {
    echo -e "\033[1;33m⚠\033[0m [${MODULE_NAME}] $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

proxy_is_reachable() {
    local proxy_url="$1"
    local host_port
    local host
    local port

    host_port="${proxy_url#*://}"
    host_port="${host_port%%/*}"
    host_port="${host_port#*@}"
    host="${host_port%%:*}"
    port="${host_port##*:}"

    if [ -z "$host" ] || [ -z "$port" ] || [ "$host" = "$port" ]; then
        return 1
    fi

    timeout 2 bash -c ":</dev/tcp/${host}/${port}" &> /dev/null
}

setup_proxy_env() {
    local env_http_proxy="${DOTFILES_HTTP_PROXY:-}"
    local env_https_proxy="${DOTFILES_HTTPS_PROXY:-}"
    local env_no_proxy="${DOTFILES_NO_PROXY:-}"
    local proxy_config="${DOTFILES_PROXY_CONFIG:-}"

    if [ -z "$proxy_config" ]; then
        proxy_config="${DOTFILES_DIR:-$MODULE_DIR/../..}/config/proxy.conf"
    fi

    if [ -f "$proxy_config" ]; then
        # shellcheck disable=SC1090
        source "$proxy_config"
    fi

    local http_proxy_value="${env_http_proxy:-${DOTFILES_HTTP_PROXY:-}}"
    local https_proxy_value="${env_https_proxy:-${DOTFILES_HTTPS_PROXY:-}}"
    local no_proxy_value="${env_no_proxy:-${DOTFILES_NO_PROXY:-}}"

    if [ -n "$http_proxy_value" ] && [ -z "$https_proxy_value" ]; then
        https_proxy_value="$http_proxy_value"
    elif [ -z "$http_proxy_value" ] && [ -n "$https_proxy_value" ]; then
        http_proxy_value="$https_proxy_value"
    fi

    if [ -n "$http_proxy_value" ] && ! proxy_is_reachable "$http_proxy_value"; then
        log_warning "HTTP 代理不可用，跳过: $http_proxy_value"
        http_proxy_value=""
    fi

    if [ -n "$https_proxy_value" ] && ! proxy_is_reachable "$https_proxy_value"; then
        log_warning "HTTPS 代理不可用，跳过: $https_proxy_value"
        https_proxy_value=""
    fi

    if [ -n "$http_proxy_value" ]; then
        export http_proxy="$http_proxy_value"
        export HTTP_PROXY="$http_proxy_value"
    else
        unset http_proxy HTTP_PROXY
    fi

    if [ -n "$https_proxy_value" ]; then
        export https_proxy="$https_proxy_value"
        export HTTPS_PROXY="$https_proxy_value"
    else
        unset https_proxy HTTPS_PROXY
    fi

    if [ -n "$no_proxy_value" ]; then
        export no_proxy="$no_proxy_value"
        export NO_PROXY="$no_proxy_value"
    fi

    if [ -n "${https_proxy:-}" ]; then
        log_info "使用 HTTPS 代理: $https_proxy"
    elif [ -n "${http_proxy:-}" ]; then
        log_info "使用 HTTP 代理: $http_proxy"
    fi
}

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
