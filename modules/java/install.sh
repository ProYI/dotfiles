#!/bin/bash
# sdkman 安装脚本
# 统一管理 JDK、Maven、Gradle、Spring Boot 等 Java 生态工具

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="java"
DEFAULT_JAVA_VERSION="21.0.2-zulu"

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

skip_existing_java() {
    if command_exists java; then
        log_warning "跳过: 检测到已有 Java，不安装 sdkman 或默认 JDK"
        return 0
    fi

    return 1
}

run_bash_without_nounset() {
    env -u SHELLOPTS bash "$@"
}

run_without_nounset() {
    local restore_nounset=false
    local restore_errexit=false

    case "$-" in
        *u*)
            restore_nounset=true
            set +u
            ;;
    esac
    case "$-" in
        *e*)
            restore_errexit=true
            set +e
            ;;
    esac

    "$@"
    local status=$?

    if [ "$restore_nounset" = true ]; then
        set -u
    fi
    if [ "$restore_errexit" = true ]; then
        set -e
    fi

    return "$status"
}

load_sdkman() {
    if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
        local restore_nounset=false
        case "$-" in
            *u*)
                restore_nounset=true
                set +u
                ;;
        esac

        # shellcheck disable=SC1091
        source "$HOME/.sdkman/bin/sdkman-init.sh"

        if [ "$restore_nounset" = true ]; then
            set -u
        fi
    fi
}

install_sdkman() {
    load_sdkman
    if command_exists sdk; then
        log_success "sdkman 已安装 (版本: $(run_without_nounset sdk version 2>&1 | head -1))"
        return 0
    fi

    log_info "安装 sdkman..."

    if ! command_exists unzip; then
        log_warning "未找到 unzip，无法自动安装 sdkman"
        return 1
    fi

    if command_exists curl; then
        curl -fsSL --connect-timeout 20 --retry 2 --retry-delay 2 "https://get.sdkman.io" | run_bash_without_nounset

        # 等待 sdkman 安装完成
        sleep 2

        # 加载 sdkman init
        load_sdkman
    else
        log_warning "未找到 curl，无法自动安装 sdkman"
        log_info "请手动安装: https://sdkman.io/install"
        return 1
    fi

    if command_exists sdk; then
        log_success "sdkman 安装完成"
        return 0
    else
        log_warning "sdkman 安装可能失败，请检查输出"
        return 1
    fi
}

install_default_jdk() {
    # 安装默认 JDK（21）
    load_sdkman
    if command_exists sdk; then
        export SDKMAN_NON_INTERACTIVE=true

        # 检查是否已安装
        if ! run_without_nounset sdk current java 2>/dev/null | grep -q "$DEFAULT_JAVA_VERSION"; then
            log_info "安装默认 JDK 21..."
            run_without_nounset sdk install java "$DEFAULT_JAVA_VERSION"
            run_without_nounset sdk default java "$DEFAULT_JAVA_VERSION"
        else
            log_success "JDK 21 已安装"
        fi
    fi
}

# 主流程
if skip_existing_java; then
    exit 0
fi

install_sdkman
install_default_jdk
