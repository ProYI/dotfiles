#!/bin/bash
# 模块环境变量模板
# 每个模块的 shell/env.sh 负责：
#   1. 设置环境变量
#   2. 初始化工具配置
#   3. 仅在交互式 shell 中生效（由 .bashrc 控制）

MODULE_NAME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." | xargs basename)"

# TODO: 在此处设置环境变量
# 示例:
# export SOME_TOOL_HOME="$HOME/.some_tool"
# export PATH="$SOME_TOOL_HOME/bin:$PATH"
