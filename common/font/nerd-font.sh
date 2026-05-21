#!/bin/bash
# Nerd Font 检测脚本
# 职责：运行时检测字体是否就绪，提示用户是否需要安装
# 安装职责在各发行版的 packages.txt 中

# 推荐的 Nerd Font 列表
RECOMMENDED_FONTS=(
    "JetBrains Mono Nerd Font"
    "Cascadia Code"
    "Fira Code Nerd Font"
)

# 中文 CJK 字体回退
CJK_FALLBACK_FONTS=(
    "Noto Sans CJK SC"
    "Noto Sans SC"
    "WenQuanYi Micro Hei"
    "Source Han Sans SC"
)

# 检测字体是否已安装（通过 fc-list）
font_installed() {
    fc-list : family | grep -qi "$1"
}

# 检测 Nerd Font
check_nerd_font() {
    local found=false
    for font in "${RECOMMENDED_FONTS[@]}"; do
        if font_installed "$font"; then
            echo "✓ Nerd Font: $font"
            found=true
            break
        fi
    done

    if [ "$found" = false ]; then
        echo "⚠ 未检测到 Nerd Font，终端图标可能无法显示"
        return 1
    fi
    return 0
}

# 检测中文 CJK 字体
check_cjk_font() {
    local found=false
    for font in "${CJK_FALLBACK_FONTS[@]}"; do
        if font_installed "$font"; then
            echo "✓ 中文字体: $font"
            found=true
            break
        fi
    done

    if [ "$found" = false ]; then
        echo "⚠ 未检测到中文字体，中文可能显示为方块"
        return 1
    fi
    return 0
}

# 主函数
case "${1:-check}" in
    check)
        check_nerd_font
        echo ""
        check_cjk_font
        ;;
    *)
        echo "用法: $0 {check}"
        ;;
esac
