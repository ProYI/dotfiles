#!/bin/bash
# 通用别名 - 适用于所有系统

# 导航
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# 列表
alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -CF'

# 安全操作
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git 快捷方式
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# 其他
alias h='history'
alias c='clear'
alias reload='source ~/.bashrc'
