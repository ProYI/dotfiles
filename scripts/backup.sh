#!/bin/bash
# 备份现有配置文件

set -euo pipefail

BACKUP_ROOT="$HOME/.dotfiles_backup"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d_%H%M%S)"
KEEP_BACKUPS=7

# 要备份的文件列表
FILES_TO_BACKUP=(
    ".dotfiles"
    ".bashrc"
    ".bash_profile"
    ".zshrc"
    ".profile"
    ".vimrc"
    ".gitconfig"
    ".tmux.conf"
    ".p10k.zsh"
    ".Xresources"
)

cleanup_old_backups() {
    local backups=()
    local backup

    shopt -s nullglob
    backups=("$BACKUP_ROOT"/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9])
    shopt -u nullglob

    if [ ${#backups[@]} -le "$KEEP_BACKUPS" ]; then
        return 0
    fi

    while IFS= read -r backup; do
        [ -n "$backup" ] || continue
        echo "删除旧备份: $backup"
        rm -rf -- "$backup"
    done < <(printf '%s\n' "${backups[@]}" | sort -r | tail -n +$((KEEP_BACKUPS + 1)))
}

echo "创建备份目录: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -e "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
        echo "备份: $file"
        cp -a "$HOME/$file" "$BACKUP_DIR/"
    fi
done

cleanup_old_backups

echo ""
echo "备份完成！"
echo "备份位置: $BACKUP_DIR"
echo ""
echo "如需恢复，运行:"
echo "  cp -a $BACKUP_DIR/. ~/"
