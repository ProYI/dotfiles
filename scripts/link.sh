#!/bin/bash
# 符号链接管理脚本

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/common.sh"

LINK_BACKUP_DIR="${DOTFILES_LINK_BACKUP_DIR:-$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)_link}"

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

        if [ "${DOTFILES_SKIP_LINK_BACKUP:-0}" = "1" ]; then
            rm -rf -- "$target"
            log_warning "已移除旧目标: $target"
        else
            mkdir -p "$LINK_BACKUP_DIR"
            mv "$target" "$LINK_BACKUP_DIR/$(basename "$target")"
            log_warning "已备份: $target -> $LINK_BACKUP_DIR/$(basename "$target")"
        fi
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

    # 链接 .p10k.zsh (Powerlevel10k 主题配置)
    if [ -f "$DOTFILES_DIR/common/shell/p10k.zsh" ]; then
        create_link "$DOTFILES_DIR/common/shell/p10k.zsh" "$HOME/.p10k.zsh"
    fi

    # .vimrc 统一使用 common 版本
    if [ -f "$DOTFILES_DIR/common/.vimrc" ]; then
        create_link "$DOTFILES_DIR/common/.vimrc" "$HOME/.vimrc"
    fi
}

# 链接 Linux 配置文件
link_linux_files() {
    echo "链接 Linux 配置文件..."

    # 链接字体配置（如果存在）
    local font_dir="$DOTFILES_DIR/linux/font"
    if [ -d "$font_dir" ]; then
        for font_conf in "$font_dir"/*; do
            [ -f "$font_conf" ] || continue
            local conf_name
            conf_name="$(basename "$font_conf")"
            # 字体配置通常放在 ~/.config/<terminal>/ 或 ~/.<terminal>
            case "$conf_name" in
                foot.conf)
                    mkdir -p "$HOME/.config/foot"
                    create_link "$font_conf" "$HOME/.config/foot/foot.conf"
                    ;;
                alacritty.toml)
                    mkdir -p "$HOME/.config/alacritty"
                    create_link "$font_conf" "$HOME/.config/alacritty/alacritty.toml"
                    ;;
                kitty.conf)
                    mkdir -p "$HOME/.config/kitty"
                    create_link "$font_conf" "$HOME/.config/kitty/kitty.conf"
                    ;;
                wezterm.lua)
                    mkdir -p "$HOME/.config/wezterm"
                    create_link "$font_conf" "$HOME/.config/wezterm/wezterm.lua"
                    ;;
            esac
        done
    fi

    # 链接 SSH 配置（如果 .ssh 目录存在）
    local ssh_dir="$DOTFILES_DIR/common/.ssh"
    if [ -d "$ssh_dir" ]; then
        local ssh_target="$HOME/.ssh"
        mkdir -p "$ssh_target"
        if [ -f "$ssh_dir/config" ]; then
            # 不覆盖已有配置，只创建模板
            if [ ! -f "$ssh_target/config" ]; then
                cp -n "$ssh_dir/config" "$ssh_target/config"
                log_success "SSH 配置模板已复制（请编辑 ~/.ssh/config 添加你的主机）"
            fi
        fi
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
