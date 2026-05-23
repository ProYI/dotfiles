#!/bin/bash
# 模块安装脚本模板
# 每个模块的 install.sh 负责：
#   1. 检测是否已安装
#   2. 执行安装逻辑
#   3. 输出安装结果

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="$(basename "$MODULE_DIR")"

# shellcheck disable=SC1091
source "$MODULE_DIR/../../scripts/lib/module.sh"

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
