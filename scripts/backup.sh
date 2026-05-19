#!/bin/bash
# 备份现有配置文件

BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# 要备份的文件列表
FILES_TO_BACKUP=(
    ".bashrc"
    ".bash_profile"
    ".zshrc"
    ".profile"
    ".vimrc"
    ".gitconfig"
    ".tmux.conf"
    ".Xresources"
)

echo "创建备份目录: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
        echo "备份: $file"
        cp -P "$HOME/$file" "$BACKUP_DIR/"
    fi
done

echo ""
echo "备份完成！"
echo "备份位置: $BACKUP_DIR"
echo ""
echo "如需恢复，运行:"
echo "  cp -r $BACKUP_DIR/* ~/"
