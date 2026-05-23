#!/bin/bash
# Shared package installation helpers for distro install scripts.

dotfiles_pm_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$dotfiles_pm_lib_dir/packages.sh"

dotfiles_load_selected_packages() {
    if [ -n "${DOTFILES_SELECTED_PACKAGES:-}" ]; then
        dotfiles_split_csv "$DOTFILES_SELECTED_PACKAGES"
        return
    fi

    dotfiles_list_config_packages
}

dotfiles_load_package_map() {
    local distro="$1"
    local map_file="$DOTFILES_DIR/distros/$distro/packages-map.sh"

    if [ -f "$map_file" ]; then
        # shellcheck disable=SC1090
        source "$map_file"
        return
    fi

    resolve_package() {
        echo "$1"
    }
}

dotfiles_pkg_installed() {
    local manager="$1"
    local pkg="$2"

    case "$manager" in
        apt)
            dpkg -s "$pkg" >/dev/null 2>&1
            ;;
        dnf)
            rpm -qi "$pkg" >/dev/null 2>&1
            ;;
        pacman)
            pacman -Qi "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

dotfiles_pkg_available() {
    local manager="$1"
    local pkg="$2"

    case "$manager" in
        apt)
            apt-cache show "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 0
            ;;
    esac
}

dotfiles_aur_pkg_installed() {
    local pkg="$1"

    if command_exists yay; then
        yay -Qi "$pkg" >/dev/null 2>&1
    elif command_exists paru; then
        paru -Qi "$pkg" >/dev/null 2>&1
    else
        return 1
    fi
}

dotfiles_collect_packages() {
    local manager="$1"
    local logical_pkg actual_pkg resolved

    while IFS= read -r logical_pkg; do
        [ -n "$logical_pkg" ] || continue

        resolved=$(resolve_package "$logical_pkg")
        for actual_pkg in $resolved; do
            if dotfiles_pkg_installed "$manager" "$actual_pkg"; then
                log_warning "检测到已有 $logical_pkg ($actual_pkg)，不重新安装" >&2
                continue
            fi

            if [ "$manager" = "pacman" ] && dotfiles_aur_pkg_installed "$actual_pkg"; then
                log_warning "检测到已有 $logical_pkg ($actual_pkg, AUR)，不重新安装" >&2
                continue
            fi

            if ! dotfiles_pkg_available "$manager" "$actual_pkg"; then
                log_warning "$logical_pkg ($actual_pkg) 不在当前软件源中，无法安装" >&2
                continue
            fi

            echo "$actual_pkg"
        done
    done < <(dotfiles_load_selected_packages)
}

dotfiles_install_selected_packages() {
    local distro="$1"
    local manager="$2"

    dotfiles_load_package_map "$distro"

    log_info "安装软件包..."
    local packages=()
    local pkg

    while IFS= read -r pkg; do
        [ -n "$pkg" ] && packages+=("$pkg")
    done < <(dotfiles_collect_packages "$manager")

    if [ ${#packages[@]} -eq 0 ]; then
        log_warning "没有需要安装的软件包"
        return 0
    fi

    case "$manager" in
        apt)
            sudo apt install -y "${packages[@]}" || true
            ;;
        dnf)
            sudo dnf install -y "${packages[@]}" || true
            ;;
        pacman)
            sudo pacman -S --needed --noconfirm "${packages[@]}" || true
            ;;
        *)
            log_warning "不支持的包管理器: $manager"
            return 1
            ;;
    esac
}
