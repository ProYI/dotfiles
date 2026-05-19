#
# ~/.bashrc
#

# 如果 .profile 存在，加载它
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
. "$HOME/.cargo/env"
