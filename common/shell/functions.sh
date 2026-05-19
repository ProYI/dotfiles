#!/bin/bash
# 通用函数 - 适用于所有系统

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 提取各种压缩文件
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' 无法被提取" ;;
        esac
    else
        echo "'$1' 不是有效文件"
    fi
}

# 查找进程
psgrep() {
    ps aux | grep -v grep | grep -i -e VSZ -e "$1"
}

# 快速备份文件
backup() {
    cp "$1"{,.bak}
}
