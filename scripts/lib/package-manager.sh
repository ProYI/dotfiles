#!/bin/bash
# Lightweight base package installer.

set -euo pipefail

package_manager_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$package_manager_lib_dir/common.sh"

dotfiles_package_manager_for_os() {
    local os="$1"

    case "$os" in
        ubuntu|debian) echo "apt" ;;
        arch|manjaro) echo "pacman" ;;
        fedora) echo "dnf" ;;
        *) echo "" ;;
    esac
}

dotfiles_resolve_package() {
    local os="$1"
    local pkg="$2"

    case "$os:$pkg" in
        ubuntu:build-tools|debian:build-tools) echo "build-essential" ;;
        ubuntu:fd|debian:fd) echo "fd-find" ;;
        arch:build-tools|manjaro:build-tools) echo "base-devel" ;;
        fedora:build-tools) echo "gcc make" ;;
        fedora:fd) echo "fd-find" ;;
        *) echo "$pkg" ;;
    esac
}

dotfiles_package_installed() {
    local manager="$1"
    local pkg="$2"

    case "$manager" in
        apt)
            dpkg -s "$pkg" >/dev/null 2>&1
            ;;
        pacman)
            pacman -Qi "$pkg" >/dev/null 2>&1
            ;;
        dnf)
            rpm -q "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

dotfiles_packages_for_category() {
    local category="$1"
    local conf_file="${2:-$DOTFILES_DIR/config/packages.conf}"
    local line key value

    if [ ! -f "$conf_file" ]; then
        log_error "软件包配置不存在: $conf_file"
        return 1
    fi

    while IFS= read -r line; do
        [ -n "$line" ] || continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" == *":"* ]] || continue

        key="${line%%:*}"
        value="${line#*:}"
        key="${key//[[:space:]]/}"

        if [ "$key" = "$category" ]; then
            echo "$value"
            return 0
        fi
    done < "$conf_file"
}

dotfiles_collect_packages() {
    local os="$1"
    local manager="$2"
    shift 2

    local logical resolved actual
    for logical in "$@"; do
        [ -n "$logical" ] || continue
        resolved="$(dotfiles_resolve_package "$os" "$logical")"
        for actual in $resolved; do
            if dotfiles_package_installed "$manager" "$actual"; then
                log_warning "已安装，跳过: $logical ($actual)" >&2
                continue
            fi
            echo "$actual"
        done
    done
}

dotfiles_split_package_categories() {
    local categories="$1"
    echo "${categories//,/ }"
}

dotfiles_install_packages() {
    local os="$1"
    local categories="${2:-base}"
    local manager

    manager="$(dotfiles_package_manager_for_os "$os")"
    if [ -z "$manager" ]; then
        log_warning "当前系统不支持自动安装基础包: $os"
        return 0
    fi

    local logical_packages=()
    local category pkg_line pkg
    for category in $(dotfiles_split_package_categories "$categories"); do
        pkg_line="$(dotfiles_packages_for_category "$category")"
        if [ -z "$pkg_line" ]; then
            log_warning "未知软件包分类，跳过: $category"
            continue
        fi
        for pkg in $pkg_line; do
            logical_packages+=("$pkg")
        done
    done

    if [ ${#logical_packages[@]} -eq 0 ]; then
        log_warning "没有选择任何软件包"
        return 0
    fi

    local packages=()
    while IFS= read -r pkg; do
        [ -n "$pkg" ] && packages+=("$pkg")
    done < <(dotfiles_collect_packages "$os" "$manager" "${logical_packages[@]}")

    if [ ${#packages[@]} -eq 0 ]; then
        log_success "基础软件包已全部安装"
        return 0
    fi

    log_info "将安装软件包: ${packages[*]}"

    case "$manager" in
        apt)
            sudo apt update
            sudo apt install -y "${packages[@]}"
            ;;
        pacman)
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        dnf)
            sudo dnf install -y "${packages[@]}"
            ;;
    esac
}
