#!/bin/bash
# Fedora 特定配置

# Fedora 特定别名
alias update='sudo dnf upgrade'
alias install='sudo dnf install'
alias remove='sudo dnf remove'
alias search='dnf search'
alias cleanup='sudo dnf autoremove && sudo dnf clean all'

# Fedora 特定工具
alias copr='sudo dnf copr'

echo "Fedora 配置已加载"
