#!/bin/bash
# rustup 环境变量初始化

# 加载 cargo 环境
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi
