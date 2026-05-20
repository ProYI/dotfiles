#!/bin/bash
# 符号链接管理脚本

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# 创建符号链接
create_link() {
    local source="$1"
    local target="$2"

    # 检查源文件是否存在
    if [ ! -e "$source" ]; then
        log_error "源文件不存在: $source"
        return 1
    fi

    # 如果目标已存在
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            # 如果已经是正确的符号链接
            if [ "$(readlink "$target")" = "$source" ]; then
                log_warning "链接已存在: $target"
                return 0
            fi
        fi

        # 备份现有文件
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$target" "$backup"
        log_warning "已备份: $target -> $backup"
    fi

    # 创建符号链接
    ln -sf "$source" "$target"
    log_success "已链接: $target -> $source"
}

# 链接通用配置文件
link_common_files() {
    echo "链接通用配置文件..."

    # 链接 .gitconfig
    if [ -f "$DOTFILES_DIR/common/.gitconfig" ]; then
        create_link "$DOTFILES_DIR/common/.gitconfig" "$HOME/.gitconfig"
    fi

    # 链接 .tmux.conf
    if [ -f "$DOTFILES_DIR/common/.tmux.conf" ]; then
        create_link "$DOTFILES_DIR/common/.tmux.conf" "$HOME/.tmux.conf"
    fi

    # .vimrc 统一使用 common 版本
    if [ -f "$DOTFILES_DIR/common/.vimrc" ]; then
        create_link "$DOTFILES_DIR/common/.vimrc" "$HOME/.vimrc"
    fi
}

# 链接 Linux 配置文件
link_linux_files() {
    echo "链接 Linux 配置文件..."

    if [ -f "$DOTFILES_DIR/linux/.Xresources" ]; then
        create_link "$DOTFILES_DIR/linux/.Xresources" "$HOME/.Xresources"
    fi
}

# 主函数
main() {
    echo "开始创建符号链接..."
    echo "Dotfiles 目录: $DOTFILES_DIR"
    echo ""

    link_common_files

    # 根据系统类型链接特定文件
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        link_linux_files
    fi

    echo ""
    echo "符号链接创建完成！"
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    main
fi
