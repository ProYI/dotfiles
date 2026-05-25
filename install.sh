#!/bin/bash
# Dotfiles installer: mirrors + base packages + backup + symlinks.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.dotfiles"
DOTFILES_DIR="$PROJECT_DIR"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$PROJECT_DIR/scripts/lib/common.sh"
# shellcheck disable=SC1091
source "$PROJECT_DIR/scripts/detect_os.sh"
# shellcheck disable=SC1091
source "$PROJECT_DIR/scripts/lib/package-manager.sh"

SKIP_MIRRORS=false
FORCE_MIRRORS=false
SKIP_PACKAGES=false
PACKAGE_CATEGORIES="base"
PACKAGE_CATEGORIES_SET=false
YES=false

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --skip-mirrors          Skip package mirror setup.
  --force-mirrors         Rewrite mirror config even if domestic mirrors exist.
  --skip-packages         Skip base package installation.
  --packages base         Install selected package categories.
  --packages base,extra   Install base and extra package categories.
  --yes, -y               Answer yes to install prompts.
  --help, -h              Show this help.
EOF
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --skip-mirrors)
                SKIP_MIRRORS=true
                ;;
            --force-mirrors)
                FORCE_MIRRORS=true
                ;;
            --skip-packages)
                SKIP_PACKAGES=true
                ;;
            --packages)
                if [ -z "${2:-}" ] || [[ "${2:-}" == -* ]]; then
                    log_error "--packages 需要指定分类，例如 base 或 base,extra"
                    exit 1
                fi
                PACKAGE_CATEGORIES="$2"
                PACKAGE_CATEGORIES_SET=true
                shift
                ;;
            --yes|-y)
                YES=true
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

confirm_step() {
    local message="$1"

    if [ "$YES" = true ]; then
        return 0
    fi

    read -r -p "$message (Y/n) " reply
    [ -z "$reply" ] || [[ "$reply" =~ ^[Yy]$ ]]
}

setup_mirrors() {
    if [ "$SKIP_MIRRORS" = true ]; then
        log_warning "跳过镜像源配置 (--skip-mirrors)"
        return 0
    fi

    if ! confirm_step "是否检查并配置国内软件源？"; then
        log_warning "跳过镜像源配置"
        return 0
    fi

    local mirror_args=()
    [ "$FORCE_MIRRORS" = true ] && mirror_args+=(--force)
    [ "$YES" = true ] && mirror_args+=(--yes)

    bash "$PROJECT_DIR/scripts/setup_mirrors.sh" "${mirror_args[@]}"
}

backup_existing_configs() {
    log_info "Backing up existing configs..."
    bash "$PROJECT_DIR/scripts/backup.sh"
}

copy_dotfiles_dir() {
    if [ "$PROJECT_DIR" = "$INSTALL_DIR" ]; then
        DOTFILES_DIR="$INSTALL_DIR"
        export DOTFILES_DIR
        log_warning "已在 ~/.dotfiles 中运行，跳过复制"
        return 0
    fi

    log_info "Copying dotfiles to $INSTALL_DIR..."
    rm -rf -- "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    (cd "$PROJECT_DIR" && tar \
        --exclude='./.git' \
        --exclude='./.idea' \
        --exclude='./.claude' \
        -cf - .) | (cd "$INSTALL_DIR" && tar -xf -)

    DOTFILES_DIR="$INSTALL_DIR"
    export DOTFILES_DIR
    log_success "Copied dotfiles to $INSTALL_DIR"
}

create_symlinks() {
    log_info "Creating symlinks..."
    DOTFILES_SKIP_LINK_BACKUP=1 bash "$DOTFILES_DIR/scripts/link.sh"

    ln -sf "$DOTFILES_DIR/common/.bashrc" "$HOME/.bashrc"
    log_success "Linked .bashrc"

    ln -sf "$DOTFILES_DIR/common/.zshrc" "$HOME/.zshrc"
    log_success "Linked .zshrc"

    ln -sf "$DOTFILES_DIR/common/shell/p10k.zsh" "$HOME/.p10k.zsh"
    log_success "Linked .p10k.zsh"

    ln -sf "$DOTFILES_DIR/common/.profile" "$HOME/.profile"
    log_success "Linked .profile"
}

install_base_packages() {
    if [ "$SKIP_PACKAGES" = true ]; then
        log_warning "跳过基础软件包安装 (--skip-packages)"
        return 0
    fi

    if [ "$PACKAGE_CATEGORIES_SET" != true ] && ! confirm_step "是否安装基础软件包 ($PACKAGE_CATEGORIES)？"; then
        log_warning "跳过基础软件包安装"
        return 0
    fi

    local os
    os="$(detect_os)"
    dotfiles_install_packages "$os" "$PACKAGE_CATEGORIES"
}

main() {
    parse_args "$@"

    local os
    os="$(detect_os)"
    log_info "检测到系统: $os"

    setup_mirrors
    backup_existing_configs
    copy_dotfiles_dir
    create_symlinks
    install_base_packages

    echo ""
    log_success "Dotfiles installed!"
    log_info "使配置生效: source ~/.bashrc 或重新打开终端"
    log_info "复杂扩展软件请参考: docs/install/README.md"
}

main "$@"
