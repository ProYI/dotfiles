#!/bin/bash
# Python 用户级脚本路径

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
