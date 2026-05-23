#!/bin/bash
# Shared shell loader for bash and zsh.

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

_dotfiles_source_file() {
    local file="$1"

    if [ -f "$file" ]; then
        source "$file"
    fi
}

_dotfiles_load_modules() {
    local modules_dir="$DOTFILES_DIR/modules"
    local modules_to_load="${DOTFILES_MODULES:-}"

    [ -d "$modules_dir" ] || return

    if [ -z "$modules_to_load" ]; then
        local mod_dir
        for mod_dir in "$modules_dir"/*/; do
            [ -d "$mod_dir" ] || continue

            local mod_name
            mod_name="$(basename "$mod_dir")"
            [ "$mod_name" = "_example" ] && continue

            [ -f "$mod_dir/shell/env.sh" ] || continue
            _dotfiles_source_file "$mod_dir/shell/env.sh"
        done
        return
    fi

    local mod_name
    for mod_name in $modules_to_load; do
        local env_file="$modules_dir/$mod_name/shell/env.sh"
        if [ -f "$env_file" ]; then
            source "$env_file"
        else
            echo "[dotfiles] warning: module $mod_name env.sh not found" >&2
        fi
    done
}

_dotfiles_load_distro() {
    [ -f /etc/os-release ] || return

    local distro_id=""
    # shellcheck disable=SC1091
    . /etc/os-release
    distro_id="${ID:-}"

    [ -n "$distro_id" ] || return
    _dotfiles_source_file "$DOTFILES_DIR/distros/$distro_id/shell/$distro_id.sh"
}

_dotfiles_load_wsl() {
    [ -r /proc/version ] || return

    if grep -qEi "(Microsoft|WSL)" /proc/version >/dev/null 2>&1; then
        _dotfiles_source_file "$DOTFILES_DIR/wsl/shell/wsl.sh"
    fi
}

_dotfiles_load_common_shell() {
    _dotfiles_source_file "$DOTFILES_DIR/common/shell/exports.sh"
    _dotfiles_source_file "$DOTFILES_DIR/common/shell/aliases.sh"
    _dotfiles_source_file "$DOTFILES_DIR/common/shell/functions.sh"

    if [[ "${OSTYPE:-}" == linux-gnu* ]]; then
        _dotfiles_source_file "$DOTFILES_DIR/linux/shell/exports.sh"
        _dotfiles_source_file "$DOTFILES_DIR/linux/shell/aliases.sh"
        _dotfiles_load_distro
        _dotfiles_load_wsl
    elif [[ "${OSTYPE:-}" == darwin* ]]; then
        _dotfiles_source_file "$DOTFILES_DIR/macos/shell/macos.sh"
    fi

    if [ "${DOTFILES_LOAD_PROFILE:-0}" = "1" ]; then
        _dotfiles_source_file "$HOME/.profile"
    fi

    if [ "${DOTFILES_LOAD_RUNTIME_EXTRAS:-0}" = "1" ]; then
        _dotfiles_source_file "$HOME/.cargo/env"
        _dotfiles_source_file "$HOME/.docker/functions.sh"
        _dotfiles_load_modules
    fi
}

_dotfiles_load_common_shell

if [ -n "${ZSH_VERSION:-}" ]; then
    unfunction _dotfiles_source_file 2>/dev/null || true
    unfunction _dotfiles_load_modules 2>/dev/null || true
    unfunction _dotfiles_load_distro 2>/dev/null || true
    unfunction _dotfiles_load_wsl 2>/dev/null || true
    unfunction _dotfiles_load_common_shell 2>/dev/null || true
else
    unset -f _dotfiles_source_file
    unset -f _dotfiles_load_modules
    unset -f _dotfiles_load_distro
    unset -f _dotfiles_load_wsl
    unset -f _dotfiles_load_common_shell
fi
