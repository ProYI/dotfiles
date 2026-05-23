#!/bin/bash
# Shared proxy helpers.

dotfiles_proxy_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$dotfiles_proxy_lib_dir/common.sh"

proxy_is_reachable() {
    local proxy_url="$1"
    local host_port host port

    host_port="${proxy_url#*://}"
    host_port="${host_port%%/*}"
    host_port="${host_port#*@}"
    host="${host_port%%:*}"
    port="${host_port##*:}"

    if [ -z "$host" ] || [ -z "$port" ] || [ "$host" = "$port" ]; then
        return 1
    fi

    timeout 2 bash -c ":</dev/tcp/${host}/${port}" >/dev/null 2>&1
}

setup_proxy_env() {
    local proxy_config="${DOTFILES_PROXY_CONFIG:-$DOTFILES_DIR/config/proxy.conf}"
    local env_http_proxy="${DOTFILES_HTTP_PROXY:-}"
    local env_https_proxy="${DOTFILES_HTTPS_PROXY:-}"
    local env_no_proxy="${DOTFILES_NO_PROXY:-}"

    if [ -f "$proxy_config" ]; then
        # shellcheck disable=SC1090
        source "$proxy_config"
    fi

    local http_proxy_value="${env_http_proxy:-${DOTFILES_HTTP_PROXY:-}}"
    local https_proxy_value="${env_https_proxy:-${DOTFILES_HTTPS_PROXY:-}}"
    local no_proxy_value="${env_no_proxy:-${DOTFILES_NO_PROXY:-}}"

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
}
