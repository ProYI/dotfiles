#!/bin/bash
# Linux aliases -- distro-aware package manager shortcuts

# Color ls and grep (universal)
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# System info
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'

# --- Distro-specific package manager aliases ---
_distro_id=""
if [ -f /etc/os-release ]; then
    _distro_id="$(. /etc/os-release && echo "${ID}")"
fi

case "$_distro_id" in
    ubuntu|debian)
        alias update='sudo apt update && sudo apt upgrade'
        alias install='sudo apt install'
        alias remove='sudo apt remove'
        alias search='apt search'
        alias cleanup='sudo apt autoremove && sudo apt autoclean'
        [ "$_distro_id" = "ubuntu" ] && alias addppa='sudo add-apt-repository'
        ;;
    fedora)
        alias update='sudo dnf upgrade'
        alias install='sudo dnf install'
        alias remove='sudo dnf remove'
        alias search='dnf search'
        alias cleanup='sudo dnf autoremove && sudo dnf clean all'
        alias copr='sudo dnf copr'
        ;;
    arch|manjaro)
        alias update='sudo pacman -Syu'
        alias install='sudo pacman -S'
        alias remove='sudo pacman -Rns'
        alias search='pacman -Ss'
        alias cleanup='sudo pacman -Sc'
        alias mirror='sudo reflector --country China --latest 10 --sort rate --save /etc/pacman.d/mirrorlist'
        if command -v yay &> /dev/null; then
            alias aur='yay' && alias aurupdate='yay -Syu'
        elif command -v paru &> /dev/null; then
            alias aur='paru' && alias aurupdate='paru -Syu'
        fi
        ;;
    *)
        alias update='sudo apt update && sudo apt upgrade'
        ;;
esac
unset _distro_id