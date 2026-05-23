#!/bin/bash
# Shared script helpers.

if [ "${DOTFILES_COMMON_LOADED:-0}" = "1" ]; then
    return 0
fi
DOTFILES_COMMON_LOADED=1

dotfiles_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$dotfiles_lib_dir/../.." && pwd)}"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$dotfiles_lib_dir/log.sh"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

dotfiles_source_if_exists() {
    local file="$1"

    if [ -f "$file" ]; then
        # shellcheck disable=SC1090
        source "$file"
    fi
}

dotfiles_split_csv() {
    local value="$1"
    local IFS=','
    local item

    for item in $value; do
        [ -n "$item" ] && echo "$item"
    done
}

dotfiles_join_by() {
    local delimiter="$1"
    shift || true

    local first=true
    local item
    for item in "$@"; do
        if [ "$first" = true ]; then
            printf "%s" "$item"
            first=false
        else
            printf "%s%s" "$delimiter" "$item"
        fi
    done
}
