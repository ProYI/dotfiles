#!/bin/bash
# rustup (Rust 工具链) 安装脚本

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="rust"
RUSTUP_DIST_SERVER="${RUSTUP_DIST_SERVER:-https://rsproxy.cn}"
RUSTUP_UPDATE_ROOT="${RUSTUP_UPDATE_ROOT:-https://rsproxy.cn/rustup}"
RUSTUP_INIT_URL="${RUSTUP_INIT_URL:-https://rsproxy.cn/rustup-init.sh}"

# shellcheck disable=SC1091
source "$MODULE_DIR/../../scripts/lib/module.sh"

load_cargo_env() {
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck disable=SC1091
        source "$HOME/.cargo/env"
    fi
}

configure_cargo_mirror() {
    local cargo_config_dir="$HOME/.cargo"
    local cargo_config="$cargo_config_dir/config.toml"

    mkdir -p "$cargo_config_dir"

    cat > "$cargo_config" <<'EOF'
[source.crates-io]
replace-with = 'rsproxy-sparse'

[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"

[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"

[net]
git-fetch-with-cli = true
EOF

    log_success "Cargo 镜像已配置: $cargo_config"
}

install_rustup() {
    load_cargo_env
    if command_exists cargo; then
        log_success "Rust 已安装 (版本: $(cargo --version 2>/dev/null | head -1))"
        configure_cargo_mirror
        return 0
    fi

    log_info "安装 rustup..."

    if command_exists curl; then
        export RUSTUP_DIST_SERVER RUSTUP_UPDATE_ROOT
        curl --proto '=https' --tlsv1.2 -sSf --connect-timeout 20 --retry 2 --retry-delay 2 "$RUSTUP_INIT_URL" | sh -s -- -y
        load_cargo_env
    else
        log_warning "未找到 curl，无法自动安装 rustup"
        return 1
    fi

    if command_exists cargo; then
        configure_cargo_mirror
        log_success "Rust 安装完成"
        return 0
    else
        log_warning "Rust 安装可能失败，请检查输出"
        return 1
    fi
}

# 主流程
install_rustup
