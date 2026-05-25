#!/bin/bash
# Shared shell loader for bash and zsh.

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

_dotfiles_source_file() {
    local file="$1"
    if [ -f "$file" ]; then
        source "$file"
    fi
}

_dotfiles_load_common_shell() {
    _dotfiles_source_file "$DOTFILES_DIR/common/shell/exports.sh"
    _dotfiles_source_file "$DOTFILES_DIR/common/shell/aliases.sh"
    _dotfiles_source_file "$DOTFILES_DIR/common/shell/functions.sh"

    if [[ "${OSTYPE:-}" == linux-gnu* ]]; then
        _dotfiles_source_file "$DOTFILES_DIR/linux/shell/exports.sh"
        _dotfiles_source_file "$DOTFILES_DIR/linux/shell/aliases.sh"
    elif [[ "${OSTYPE:-}" == darwin* ]]; then
        _dotfiles_source_file "$DOTFILES_DIR/macos/shell/macos.sh"
    fi

    if [ "${DOTFILES_LOAD_RUNTIME_EXTRAS:-0}" = "1" ]; then
        _dotfiles_source_file "$DOTFILES_DIR/common/shell/runtime.sh"
    fi

    if [ "${DOTFILES_LOAD_PROFILE:-0}" = "1" ]; then
        _dotfiles_source_file "$HOME/.profile"
    fi
}

_dotfiles_load_common_shell

if [ -n "${ZSH_VERSION:-}" ]; then
    unfunction _dotfiles_source_file 2>/dev/null || true
    unfunction _dotfiles_load_common_shell 2>/dev/null || true
else
    unset -f _dotfiles_source_file
    unset -f _dotfiles_load_common_shell
fi