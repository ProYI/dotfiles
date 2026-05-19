#!/bin/bash
# Linux 通用别名

# 系统管理
alias update='sudo apt update && sudo apt upgrade'  # 默认，各发行版会覆盖
alias cleanup='sudo apt autoremove && sudo apt autoclean'

# 列表（Linux 特定选项）
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# 系统信息
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
