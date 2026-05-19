#!/bin/bash
# Debian 特定配置

# Debian 特定别名（与 Ubuntu 类似）
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias search='apt search'
alias cleanup='sudo apt autoremove && sudo apt autoclean'

echo "Debian 配置已加载"
