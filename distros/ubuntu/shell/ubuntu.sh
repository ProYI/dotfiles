#!/bin/bash
# Ubuntu/Debian 特定配置

# Ubuntu/Debian 特定别名
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias search='apt search'
alias cleanup='sudo apt autoremove && sudo apt autoclean'

# PPA 管理
alias addppa='sudo add-apt-repository'

echo "Ubuntu/Debian 配置已加载"
