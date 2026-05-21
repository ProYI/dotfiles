#!/bin/bash
# sdkman 环境变量初始化
# sdkman 管理 JAVA_HOME, M2_HOME, GRADLE_HOME 等

# sdkman 初始化
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
