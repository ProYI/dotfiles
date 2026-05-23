#!/bin/bash
# fnm (Fast Node Manager) 安装脚本
# 比 nvm 更快，Rust 编写，环境变量加载几乎零开销

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="node"

# shellcheck disable=SC1091
source "$MODULE_DIR/../../scripts/lib/module.sh"
# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/proxy.sh"

skip_existing_node() {
    if command_exists node; then
        log_warning "跳过: 检测到已有 Node.js ($(node --version 2>/dev/null || echo unknown))，不安装 fnm 或默认 Node 版本"
        return 0
    fi

    return 1
}

setup_node_proxy_env() {
    local env_fnm_node_dist_mirror="${FNM_NODE_DIST_MIRROR:-}"
    setup_proxy_env

    local fnm_node_dist_mirror_value="${env_fnm_node_dist_mirror:-${FNM_NODE_DIST_MIRROR:-}}"
    if [ -n "$fnm_node_dist_mirror_value" ]; then
        export FNM_NODE_DIST_MIRROR="$fnm_node_dist_mirror_value"
    fi
}

load_fnm_path() {
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"
}

install_fnm() {
    load_fnm_path
    if command_exists fnm; then
        log_success "fnm 已安装 (版本: $(fnm --version))"
        return 0
    fi

    log_info "安装 fnm..."
    setup_node_proxy_env

    # 使用官方安装脚本
    if command_exists curl; then
        curl -fsSL --connect-timeout 20 --retry 2 --retry-delay 2 https://fnm.vercel.app/install | run_bash_without_nounset
        load_fnm_path
    else
        log_warning "未找到 curl，无法自动安装 fnm"
        log_info "请手动安装: https://github.com/Schniz/fnm#quickstart"
        return 1
    fi

    if command_exists fnm; then
        log_success "fnm 安装完成"
        return 0
    else
        log_warning "fnm 安装可能失败，请检查输出"
        return 1
    fi
}

install_default_node() {
    load_fnm_path
    if ! command_exists fnm; then
        return 1
    fi

    # 安装 LTS 版本作为默认版本
    setup_node_proxy_env
    local default_version
    default_version=$(fnm list-remote | grep -E "^ *v20\\." | tail -1 | awk '{print $1}')

    if [ -n "$default_version" ]; then
        log_info "设置默认 Node 版本: $default_version"
        fnm install "$default_version" --progress=always
        fnm default "$default_version"
    fi
}

# 主流程
if skip_existing_node; then
    exit 0
fi

install_fnm
install_default_node
