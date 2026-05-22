#!/bin/bash
# Docker + Docker Compose 安装脚本

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="docker"

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

command_exists() {
    command -v "$1" &> /dev/null
}

skip_existing_docker() {
    if command_exists docker; then
        log_warning "跳过: 检测到已有 Docker，不修改安装、用户组或镜像配置"
        return 0
    fi

    return 1
}

# 通过包管理器安装 Docker（优先）
install_docker_pkg() {
    local distro_id
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        distro_id="$ID"
    else
        distro_id=""
    fi

    case "$distro_id" in
        arch|manjaro)
            if ! command_exists docker; then
                log_info "通过 pacman 安装 Docker..."
                sudo pacman -S --needed --noconfirm docker docker-compose
                log_success "Docker 安装完成"
            else
                log_success "Docker 已安装"
            fi
            ;;
        ubuntu|debian)
            if ! command_exists docker; then
                log_info "通过系统仓库安装 Docker..."
                # 安装依赖
                sudo apt-get update
                sudo apt-get install -y docker.io docker-compose

                log_success "Docker 安装完成"
            else
                log_success "Docker 已安装"
            fi
            ;;
        fedora)
            if ! command_exists docker; then
                log_info "通过 dnf 安装 Docker..."
                sudo dnf install -y moby-engine docker-compose
                sudo systemctl enable --now docker 2>/dev/null || true
                log_success "Docker 安装完成"
            else
                log_success "Docker 已安装"
            fi
            ;;
        *)
            log_warning "不支持的发行版: $distro_id，请手动安装 Docker"
            return 1
            ;;
    esac
}

# 将用户加入 docker 组（免 sudo）
add_user_to_docker_group() {
    local target_user="${SUDO_USER:-${USER:-$(id -un)}}"

    if getent group docker >/dev/null 2>&1 && id -nG "$target_user" | grep -qw docker; then
        return 0
    fi

    log_info "将用户 $target_user 加入 docker 组..."
    sudo groupadd -f docker 2>/dev/null || true
    sudo usermod -aG docker "$target_user"
    log_success "用户已加入 docker 组（需要重新登录生效）"
}

# 配置 Docker 镜像加速
setup_docker_mirror() {
    local mirror_conf="$HOME/.docker/daemon.json"
    local mirror_env_file="$HOME/.docker/mirror.conf"

    # 加载镜像配置
    local mirror="docker.1ms.run"
    if [ -f "$mirror_env_file" ]; then
        source "$mirror_env_file"
        mirror="${DOCKER_MIRROR:-docker.1ms.run}"
    fi

    # 创建 daemon.json
    mkdir -p "$HOME/.docker"
    if [ ! -f "$mirror_conf" ]; then
        cat > "$mirror_conf" <<EOF
{
    "registry-mirrors": ["https://$mirror"]
}
EOF
        log_success "Docker 镜像配置已创建"

        # 重启 Docker（仅 Linux）
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo systemctl restart docker 2>/dev/null || true
        fi
    fi
}

# 主流程
if skip_existing_docker; then
    exit 0
fi

install_docker_pkg
add_user_to_docker_group
setup_docker_mirror
