#!/bin/bash
# 模块安装脚本模板
# 每个模块的 install.sh 负责：
#   1. 检测是否已安装
#   2. 执行安装逻辑
#   3. 输出安装结果

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="$(basename "$MODULE_DIR")"

log_info() {
    echo -e "\033[0;34m==>\033[0m [${MODULE_NAME}] $1"
}

log_success() {
    echo -e "\033[0;32m✓\033[0m [${MODULE_NAME}] $1"
}

log_warning() {
    echo -e "\033[1;33m⚠\033[0m [${MODULE_NAME}] $1"
}

log_error() {
    echo -e "\033[0;31m✗\033[0m [${MODULE_NAME}] $1"
}

# 检测命令是否存在
command_exists() {
    command -v "$1" &> /dev/null
}

# 主安装函数
install_module() {
    log_info "开始安装 ${MODULE_NAME} 模块..."

    # TODO: 在此处实现安装逻辑
    # 示例:
    # if command_exists some_tool; then
    #     log_success "some_tool 已安装，跳过"
    # else
    #     # 执行安装...
    # fi

    log_success "${MODULE_NAME} 模块安装完成"
}

# 支持 --dry-run 参数
if [[ "${1:-}" == "--dry-run" ]]; then
    log_info "Dry-run 模式，仅展示计划操作"
    exit 0
fi

install_module
