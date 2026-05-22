#!/bin/bash
# fnm 环境变量初始化

# fnm 初始化脚本
# 必须在 shell 启动时调用，设置 PATH 和 shell hook
if [ -d "$HOME/.local/share/fnm" ]; then
    export PATH="$HOME/.local/share/fnm:$PATH"
fi

if command -v fnm &> /dev/null; then
    # 使用 eval 让 fnm 注入 shell 函数
    eval "$(fnm env --use-on-cd)"
fi
