#!/bin/bash
# Dotfiles runtime verification script

set -u

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/common.sh"
# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/packages.sh"

CHECK_SCOPE="${1:-all}"
FAILED=0
SELECTED_PACKAGES_LOADED=false
SELECTED_MODULES_LOADED=false
SELECTED_PACKAGES=()
SELECTED_MODULES=()

section() {
    echo ""
    echo -e "${BLUE}==>${NC} $1"
}

pass() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
    FAILED=1
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID:-unknown}"
    else
        echo "unknown"
    fi
}

load_selected_packages() {
    if [ "$SELECTED_PACKAGES_LOADED" = true ]; then
        return
    fi

    if [ -n "${DOTFILES_SELECTED_PACKAGES:-}" ]; then
        while IFS= read -r item; do
            SELECTED_PACKAGES+=("$item")
        done < <(dotfiles_split_csv "$DOTFILES_SELECTED_PACKAGES")
    else
        while IFS= read -r item; do
            SELECTED_PACKAGES+=("$item")
        done < <(dotfiles_list_config_packages)
    fi

    SELECTED_PACKAGES_LOADED=true
}

load_selected_modules() {
    if [ "$SELECTED_MODULES_LOADED" = true ]; then
        return
    fi

    if [ -n "${DOTFILES_SELECTED_MODULES:-}" ]; then
        while IFS= read -r item; do
            SELECTED_MODULES+=("$item")
        done < <(dotfiles_split_csv "$DOTFILES_SELECTED_MODULES")
    fi

    SELECTED_MODULES_LOADED=true
}

package_selected() {
    local wanted="$1"
    local package

    load_selected_packages
    for package in "${SELECTED_PACKAGES[@]}"; do
        [ "$package" = "$wanted" ] && return 0
    done

    return 1
}

module_selected() {
    local wanted="$1"
    local module

    load_selected_modules
    for module in "${SELECTED_MODULES[@]}"; do
        [ "$module" = "$wanted" ] && return 0
    done

    return 1
}

load_module_envs() {
    local modules_dir="$DOTFILES_DIR/modules"
    local restore_nounset=false

    [ -d "$modules_dir" ] || return
    load_selected_modules
    [ "${#SELECTED_MODULES[@]}" -gt 0 ] || return

    case "$-" in
        *u*)
            restore_nounset=true
            set +u
            ;;
    esac

    local module env_file
    for module in "${SELECTED_MODULES[@]}"; do
        env_file="$modules_dir/$module/shell/env.sh"
        [ -f "$env_file" ] || continue
        # shellcheck disable=SC1090
        source "$env_file"
    done

    if [ "$restore_nounset" = true ]; then
        set -u
    fi
}

link_points_to() {
    local target="$1"
    local expected="$2"

    [ -L "$target" ] && [ "$(readlink "$target")" = "$expected" ]
}

check_link() {
    local label="$1"
    local target="$2"
    local expected="$3"

    if link_points_to "$target" "$expected"; then
        pass "$label: $target -> $expected"
    elif [ -e "$target" ] || [ -L "$target" ]; then
        fail "$label: $target exists but does not point to $expected"
    else
        fail "$label: missing $target"
    fi
}

check_shell() {
    section "Shell"

    check_link "bash config" "$HOME/.bashrc" "$DOTFILES_DIR/common/.bashrc"

    if command_exists bash; then
        if bash -ic 'type ll >/dev/null && type gs >/dev/null && type extract >/dev/null' >/dev/null 2>&1; then
            pass "bash runtime: aliases and functions are available"
        else
            fail "bash runtime: failed to load ll/gs/extract"
        fi
    else
        fail "bash command: not found"
    fi

    check_link "zsh config" "$HOME/.zshrc" "$DOTFILES_DIR/common/.zshrc"

    if command_exists zsh; then
        pass "zsh command: $(command -v zsh)"
        if zsh -n "$DOTFILES_DIR/common/.zshrc" >/dev/null 2>&1; then
            pass "zsh config syntax: passed"
        else
            fail "zsh config syntax: failed"
        fi
    else
        fail "zsh command: not found"
    fi
}

font_family_available() {
    local family="$1"
    fc-list : family 2>/dev/null | grep -qi "$family"
}

check_fonts() {
    section "Fonts"

    local should_check_nerd=false
    local should_check_cjk=false

    if module_selected nerd-font; then
        should_check_nerd=true
    fi
    if package_selected cjk-font; then
        should_check_cjk=true
    fi

    if [ "$should_check_nerd" = false ] && [ "$should_check_cjk" = false ]; then
        warn "fonts: no selected font packages/modules, skipped"
        return
    fi

    if ! command_exists fc-list || ! command_exists fc-match; then
        fail "fontconfig: fc-list/fc-match not found"
        return
    fi

    local nerd_fonts=(
        "JetBrainsMono Nerd Font"
        "JetBrains Mono Nerd Font"
        "Cascadia Code"
        "Fira Code Nerd Font"
    )
    local cjk_fonts=(
        "Noto Sans CJK SC"
        "Noto Sans SC"
        "WenQuanYi Micro Hei"
        "Source Han Sans SC"
    )

    local found_nerd=""
    local font
    for font in "${nerd_fonts[@]}"; do
        if font_family_available "$font"; then
            found_nerd="$font"
            break
        fi
    done

    if [ "$should_check_nerd" = true ]; then
        if [ -n "$found_nerd" ]; then
            pass "Nerd Font: $found_nerd"
            pass "font match: $(fc-match "$found_nerd" | head -1)"
        else
            fail "Nerd Font: no recommended Nerd Font found"
        fi
    else
        warn "Nerd Font: skipped (module not selected)"
    fi

    local found_cjk=""
    for font in "${cjk_fonts[@]}"; do
        if font_family_available "$font"; then
            found_cjk="$font"
            break
        fi
    done

    if [ "$should_check_cjk" = true ]; then
        if [ -n "$found_cjk" ]; then
            pass "CJK Font: $found_cjk"
            pass "font match: $(fc-match "$found_cjk" | head -1)"
        else
            fail "CJK Font: no recommended CJK font found"
        fi
    else
        warn "CJK Font: skipped (package not selected)"
    fi
}

check_terminal_links() {
    section "Terminal Configs"

    if [[ "${OSTYPE:-}" != linux-gnu* ]]; then
        warn "terminal font links: skipped on non-Linux OSTYPE=${OSTYPE:-unknown}"
        return
    fi

    check_link "foot config" "$HOME/.config/foot/foot.conf" "$DOTFILES_DIR/linux/font/foot.conf"
    check_link "alacritty config" "$HOME/.config/alacritty/alacritty.toml" "$DOTFILES_DIR/linux/font/alacritty.toml"
    check_link "kitty config" "$HOME/.config/kitty/kitty.conf" "$DOTFILES_DIR/linux/font/kitty.conf"
    check_link "wezterm config" "$HOME/.config/wezterm/wezterm.lua" "$DOTFILES_DIR/linux/font/wezterm.lua"
}

check_module_file() {
    local module="$1"
    local env_file="$DOTFILES_DIR/modules/$module/shell/env.sh"
    local install_file="$DOTFILES_DIR/modules/$module/install.sh"

    if [ -f "$install_file" ]; then
        pass "$module module install: $install_file"
    else
        fail "$module module install: missing $install_file"
    fi

    if [ -f "$env_file" ]; then
        pass "$module module env: $env_file"
    fi
}

check_tool_version() {
    local label="$1"
    local command_name="$2"
    shift 2

    if command_exists "$command_name"; then
        local version
        version=$("$@" 2>/dev/null | head -1 || true)
        if [ -n "$version" ]; then
            pass "$label: $version"
        else
            pass "$label: $(command -v "$command_name")"
        fi
    else
        fail "$label: $command_name not found"
    fi
}

check_modules() {
    section "Modules"

    local modules_dir="$DOTFILES_DIR/modules"
    if [ ! -d "$modules_dir" ]; then
        warn "modules directory not found: $modules_dir"
        return
    fi

    load_module_envs

    local module
    load_selected_modules

    if [ "${#SELECTED_MODULES[@]}" -eq 0 ]; then
        warn "modules: no selected modules, skipped"
        return
    fi

    for module in "${SELECTED_MODULES[@]}"; do
        if [ -d "$modules_dir/$module" ]; then
            check_module_file "$module"
        else
            fail "$module module: missing $modules_dir/$module"
        fi
    done

    module_selected python && check_tool_version "python" python3 python3 --version
    if module_selected node; then
        if command_exists fnm; then
            check_tool_version "node manager" fnm fnm --version
        else
            check_tool_version "node" node node --version
        fi
    fi
    module_selected java && check_tool_version "java" java java -version
    module_selected rust && check_tool_version "rust" cargo cargo --version
    module_selected docker && check_tool_version "docker client" docker docker --version
    module_selected eza && check_tool_version "eza" eza eza --version
}

run_scope() {
    case "$CHECK_SCOPE" in
        all)
            check_shell
            check_fonts
            check_terminal_links
            check_modules
            ;;
        shell)
            check_shell
            ;;
        fonts)
            check_fonts
            ;;
        links)
            check_terminal_links
            ;;
        modules)
            check_modules
            ;;
        *)
            echo "Usage: $0 {all|shell|fonts|links|modules}" >&2
            exit 2
            ;;
    esac
}

echo "Dotfiles 验收检查"
echo "DOTFILES_DIR: $DOTFILES_DIR"

run_scope

echo ""
if [ "$FAILED" -eq 0 ]; then
    pass "Dotfiles 验收通过"
else
    fail "Dotfiles 验收失败"
fi

exit "$FAILED"
