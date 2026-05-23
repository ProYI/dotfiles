#!/bin/bash
# eza 安装脚本：系统仓库优先，必要时使用上游 apt 源或 cargo 兜底。

set -euo pipefail

MODULE_NAME="eza"

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

skip_existing_eza() {
    if command_exists eza; then
        log_success "eza 已安装 (版本: $(eza --version 2>/dev/null | head -1))"
        return 0
    fi

    return 1
}

apt_package_available() {
    apt-cache show "$1" &> /dev/null
}

install_from_package_manager() {
    if command_exists apt-get; then
        sudo apt-get update
        if apt_package_available eza; then
            log_info "通过 apt 安装 eza..."
            sudo apt-get install -y eza
            return 0
        fi

        return 1
    fi

    if command_exists dnf; then
        if dnf list --available eza &> /dev/null; then
            log_info "通过 dnf 安装 eza..."
            sudo dnf install -y eza
            return 0
        fi

        return 1
    fi

    if command_exists pacman; then
        if pacman -Si eza &> /dev/null; then
            log_info "通过 pacman 安装 eza..."
            sudo pacman -S --needed --noconfirm eza
            return 0
        fi

        return 1
    fi

    if command_exists brew; then
        log_info "通过 Homebrew 安装 eza..."
        brew install eza
        return 0
    fi

    return 1
}

download_eza_key() {
    if command_exists wget; then
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc
        return
    fi

    if command_exists curl; then
        curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc
        return
    fi

    return 1
}

install_from_eza_apt_repo() {
    if ! command_exists apt-get; then
        return 1
    fi

    if ! command_exists gpg; then
        sudo apt-get update
        sudo apt-get install -y gpg
    fi

    if ! command_exists wget && ! command_exists curl; then
        sudo apt-get update
        sudo apt-get install -y wget
    fi

    log_info "添加 eza 官方 apt 源..."
    sudo mkdir -p /etc/apt/keyrings
    download_eza_key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

    sudo apt-get update
    sudo apt-get install -y eza
}

install_from_cargo() {
    if ! command_exists cargo; then
        return 1
    fi

    log_info "通过 cargo 安装 eza..."
    cargo install eza
}

if skip_existing_eza; then
    exit 0
fi

if install_from_package_manager || install_from_eza_apt_repo || install_from_cargo; then
    if command_exists eza; then
        log_success "eza 安装完成"
        exit 0
    fi
fi

log_warning "eza 自动安装失败，请检查发行版仓库、网络或手动安装"
exit 1
