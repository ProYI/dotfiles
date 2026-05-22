#!/bin/bash
# fnm (Fast Node Manager) 安装脚本
# 比 nvm 更快，Rust 编写，环境变量加载几乎零开销

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="node"

log_info() {
    echo -e "\033[0;34m==>\033[0m [${MODULE_NAME}] $1"
}

log_success() {
    echo -e "\033[0;32m✓\033[0m [${MODULE_NAME}] $1"
}

log_warning() {
    echo -e "\033[1;33m⚠\033[0m [${MODULE_NAME}] $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

skip_existing_node() {
    if command_exists node; then
        log_warning "跳过: 检测到已有 Node.js ($(node --version 2>/dev/null || echo unknown))，不安装 fnm 或默认 Node 版本"
        return 0
    fi

    return 1
}

run_bash_without_nounset() {
    env -u SHELLOPTS bash "$@"
}

proxy_is_reachable() {
    local proxy_url="$1"
    local host_port
    local host
    local port

    host_port="${proxy_url#*://}"
    host_port="${host_port%%/*}"
    host_port="${host_port#*@}"
    host="${host_port%%:*}"
    port="${host_port##*:}"

    if [ -z "$host" ] || [ -z "$port" ] || [ "$host" = "$port" ]; then
        return 1
    fi

    timeout 2 bash -c ":</dev/tcp/${host}/${port}" &> /dev/null
}

setup_proxy_env() {
    local env_http_proxy="${DOTFILES_HTTP_PROXY:-}"
    local env_https_proxy="${DOTFILES_HTTPS_PROXY:-}"
    local env_no_proxy="${DOTFILES_NO_PROXY:-}"
    local env_fnm_node_dist_mirror="${FNM_NODE_DIST_MIRROR:-}"
    local proxy_config="${DOTFILES_PROXY_CONFIG:-}"

    if [ -z "$proxy_config" ]; then
        proxy_config="${DOTFILES_DIR:-$MODULE_DIR/../..}/config/proxy.conf"
    fi

    if [ -f "$proxy_config" ]; then
        # shellcheck disable=SC1090
        source "$proxy_config"
    fi

    local http_proxy_value="${env_http_proxy:-${DOTFILES_HTTP_PROXY:-}}"
    local https_proxy_value="${env_https_proxy:-${DOTFILES_HTTPS_PROXY:-}}"
    local no_proxy_value="${env_no_proxy:-${DOTFILES_NO_PROXY:-}}"
    local fnm_node_dist_mirror_value="${env_fnm_node_dist_mirror:-${FNM_NODE_DIST_MIRROR:-}}"

    if [ -n "$http_proxy_value" ] && [ -z "$https_proxy_value" ]; then
        https_proxy_value="$http_proxy_value"
    elif [ -z "$http_proxy_value" ] && [ -n "$https_proxy_value" ]; then
        http_proxy_value="$https_proxy_value"
    fi

    if [ -n "$http_proxy_value" ] && ! proxy_is_reachable "$http_proxy_value"; then
        log_warning "HTTP 代理不可用，跳过: $http_proxy_value"
        http_proxy_value=""
    fi

    if [ -n "$https_proxy_value" ] && ! proxy_is_reachable "$https_proxy_value"; then
        log_warning "HTTPS 代理不可用，跳过: $https_proxy_value"
        https_proxy_value=""
    fi

    if [ -n "$http_proxy_value" ]; then
        export http_proxy="$http_proxy_value"
        export HTTP_PROXY="$http_proxy_value"
    else
        unset http_proxy HTTP_PROXY
    fi

    if [ -n "$https_proxy_value" ]; then
        export https_proxy="$https_proxy_value"
        export HTTPS_PROXY="$https_proxy_value"
    else
        unset https_proxy HTTPS_PROXY
    fi

    if [ -n "$no_proxy_value" ]; then
        export no_proxy="$no_proxy_value"
        export NO_PROXY="$no_proxy_value"
    fi

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
    setup_proxy_env

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
    setup_proxy_env
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
