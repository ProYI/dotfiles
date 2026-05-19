#!/bin/bash
# Dotfiles 主安装脚本

set -e

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Dotfiles 目录
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

log_info() {
    echo -e "${BLUE}==>${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# 加载系统检测脚本
source "$DOTFILES_DIR/scripts/detect_os.sh"

# 显示欢迎信息
show_banner() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║     Dotfiles 安装脚本                 ║"
    echo "║     多系统配置管理                    ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
}

# 备份现有配置
backup_existing() {
    log_info "备份现有配置..."
    bash "$DOTFILES_DIR/scripts/backup.sh"
}

# 创建符号链接
create_symlinks() {
    log_info "创建符号链接..."

    # 链接 .bashrc
    if [ -f "$DOTFILES_DIR/common/.bashrc" ]; then
        ln -sf "$DOTFILES_DIR/common/.bashrc" "$HOME/.bashrc"
        log_success "已链接 .bashrc"
    fi

    # 链接 .profile
    if [ -f "$DOTFILES_DIR/common/.profile" ]; then
        ln -sf "$DOTFILES_DIR/common/.profile" "$HOME/.profile"
        log_success "已链接 .profile"
    fi

    # 运行通用链接脚本
    bash "$DOTFILES_DIR/scripts/link.sh"
}

# 安装发行版特定配置
install_distro_specific() {
    local distro="$1"
    local install_script="$DOTFILES_DIR/distros/$distro/install.sh"

    if [ -f "$install_script" ]; then
        log_info "运行 $distro 特定安装脚本..."
        bash "$install_script"
    else
        log_warning "未找到 $distro 的安装脚本"
    fi
}

# 配置镜像源
setup_mirrors() {
    log_info "配置国内镜像源..."
    if [ -f "$DOTFILES_DIR/scripts/setup_mirrors.sh" ]; then
        bash "$DOTFILES_DIR/scripts/setup_mirrors.sh"
    else
        log_warning "未找到镜像源配置脚本，跳过"
    fi
}

# 主安装流程
main() {
    show_banner

    # 检测操作系统
    OS=$(detect_os)
    log_info "检测到操作系统: $OS"

    # 检测 WSL
    if detect_wsl; then
        log_info "检测到 WSL 环境"
    fi

    echo ""
    read -p "是否配置国内镜像源？(推荐) (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_mirrors
    fi

    echo ""
    read -p "是否备份现有配置？(y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        backup_existing
    fi

    echo ""
    log_info "开始安装..."

    # 创建符号链接
    create_symlinks

    # 根据操作系统执行特定安装
    case "$OS" in
        arch)
            install_distro_specific "arch"
            ;;
        ubuntu)
            install_distro_specific "ubuntu"
            ;;
        debian)
            install_distro_specific "debian"
            ;;
        fedora)
            install_distro_specific "fedora"
            ;;
        manjaro)
            install_distro_specific "manjaro"
            ;;
        macos)
            log_info "macOS 配置..."
            # macOS 特定安装逻辑
            ;;
        *)
            log_warning "未知的操作系统: $OS"
            log_info "仅安装通用配置"
            ;;
    esac

    echo ""
    log_success "安装完成！"
    echo ""
    log_info "请运行以下命令使配置生效:"
    echo "  source ~/.bashrc"
    echo ""
    log_info "或者重新登录系统"
}

# 运行主函数
main "$@"
