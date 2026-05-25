#!/bin/bash
# Detect current operating system / Linux distribution.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/common.sh"

detect_os() {
    case "${OSTYPE:-}" in
        darwin*)
            echo "macos"
            return 0
            ;;
        linux*)
            ;;
        *)
            echo "unknown"
            return 0
            ;;
    esac

    if [ ! -f /etc/os-release ]; then
        echo "unknown"
        return 0
    fi

    local id id_like
    id=""
    id_like=""
    # shellcheck disable=SC1091
    . /etc/os-release
    id="${ID:-}"
    id_like="${ID_LIKE:-}"

    case "$id" in
        ubuntu|debian|arch|manjaro|fedora)
            echo "$id"
            ;;
        *)
            case " $id_like " in
                *" debian "*) echo "debian" ;;
                *" arch "*) echo "arch" ;;
                *" fedora "*) echo "fedora" ;;
                *) echo "unknown" ;;
            esac
            ;;
    esac
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    detect_os
fi
