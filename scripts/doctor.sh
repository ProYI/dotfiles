#!/bin/bash
# Dotfiles runtime verification script

set -u

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CHECK_SCOPE="${1:-all}"
FAILED=0

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

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

load_module_envs() {
    local modules_dir="$DOTFILES_DIR/modules"
    local restore_nounset=false

    [ -d "$modules_dir" ] || return

    case "$-" in
        *u*)
            restore_nounset=true
            set +u
            ;;
    esac

    local env_file
    for env_file in "$modules_dir"/*/shell/env.sh; do
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
        if zsh -i -c 'echo "[doctor] zsh runtime ok"' >/dev/null 2>&1; then
            pass "zsh runtime: interactive startup passed"
        else
            fail "zsh runtime: interactive startup failed"
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

    if ! command_exists fc-list || ! command_exists fc-match; then
        fail "fontconfig: fc-list/fc-match not found"
        return
    fi

    local nerd_fonts=(
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

    if [ -n "$found_nerd" ]; then
        pass "Nerd Font: $found_nerd"
        pass "font match: $(fc-match "$found_nerd" | head -1)"
    else
        fail "Nerd Font: no recommended Nerd Font found"
    fi

    local found_cjk=""
    for font in "${cjk_fonts[@]}"; do
        if font_family_available "$font"; then
            found_cjk="$font"
            break
        fi
    done

    if [ -n "$found_cjk" ]; then
        pass "CJK Font: $found_cjk"
        pass "font match: $(fc-match "$found_cjk" | head -1)"
    else
        fail "CJK Font: no recommended CJK font found"
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

    if [ -f "$env_file" ]; then
        pass "$module module env: $env_file"
    else
        fail "$module module env: missing $env_file"
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
        warn "$label: $command_name not found"
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
    for module in node java python rust docker; do
        if [ -d "$modules_dir/$module" ]; then
            check_module_file "$module"
        fi
    done

    check_tool_version "python" python3 python3 --version
    check_tool_version "node manager" fnm fnm --version
    check_tool_version "java" java java -version
    check_tool_version "rust" cargo cargo --version
    check_tool_version "docker client" docker docker --version
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
