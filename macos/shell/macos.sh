#!/bin/bash
# macOS 特定配置

# Homebrew
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# macOS 特定别名
alias update='brew update && brew upgrade'
alias install='brew install'
alias search='brew search'
alias cleanup='brew cleanup'

# macOS 特定
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

echo "macOS 配置已加载"
