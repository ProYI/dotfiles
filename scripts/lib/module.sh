#!/bin/bash
# Shared helpers for module install scripts.

MODULE_DIR="${MODULE_DIR:-$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}"
MODULE_NAME="${MODULE_NAME:-$(basename "$MODULE_DIR")}"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$MODULE_DIR/../.." && pwd)}"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/common.sh"

module_log_info() {
    echo -e "${DOTFILES_COLOR_BLUE}==>${DOTFILES_COLOR_RESET} [${MODULE_NAME}] $1"
}

module_log_success() {
    echo -e "${DOTFILES_COLOR_GREEN}OK${DOTFILES_COLOR_RESET} [${MODULE_NAME}] $1"
}

module_log_warning() {
    echo -e "${DOTFILES_COLOR_YELLOW}WARN${DOTFILES_COLOR_RESET} [${MODULE_NAME}] $1"
}

module_log_error() {
    echo -e "${DOTFILES_COLOR_RED}ERR${DOTFILES_COLOR_RESET} [${MODULE_NAME}] $1"
}

log_info() {
    module_log_info "$1"
}

log_success() {
    module_log_success "$1"
}

log_warning() {
    module_log_warning "$1"
}

log_error() {
    module_log_error "$1"
}

run_bash_without_nounset() {
    env -u SHELLOPTS bash "$@"
}
