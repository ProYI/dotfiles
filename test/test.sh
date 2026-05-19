#!/bin/bash
# Docker 测试脚本 - 在容器中测试 dotfiles 安装

set -e

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}==>${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# 支持的发行版
DISTROS=("arch" "ubuntu" "debian" "fedora")

# 显示使用说明
show_usage() {
    cat << EOF
用法: $0 [选项] [发行版]

选项:
  -h, --help          显示此帮助信息
  -a, --all           测试所有发行版
  -b, --build         重新构建镜像
  -c, --clean         清理测试容器和镜像
  -i, --interactive   交互式模式（进入容器 shell）

发行版:
  arch                测试 Arch Linux
  ubuntu              测试 Ubuntu
  debian              测试 Debian
  fedora              测试 Fedora

示例:
  $0 arch                    # 测试 Arch Linux
  $0 -a                      # 测试所有发行版
  $0 -b ubuntu               # 重新构建并测试 Ubuntu
  $0 -i arch                 # 交互式进入 Arch 容器
  $0 -c                      # 清理所有测试容器

EOF
}

# 构建 Docker 镜像
build_image() {
    local distro=$1
    local dockerfile="test/dockerfiles/Dockerfile.$distro"

    if [ ! -f "$dockerfile" ]; then
        log_error "找不到 Dockerfile: $dockerfile"
        return 1
    fi

    log_info "构建 $distro 镜像..."
    docker build -f "$dockerfile" -t "dotfiles-test-$distro" .
    log_success "$distro 镜像构建完成"
}

# 运行测试
run_test() {
    local distro=$1
    local interactive=$2

    log_info "测试 $distro..."

    # 检查镜像是否存在
    if ! docker image inspect "dotfiles-test-$distro" &> /dev/null; then
        log_info "镜像不存在，开始构建..."
        build_image "$distro"
    fi

    # 容器名称
    local container_name="dotfiles-test-$distro-$(date +%s)"

    if [ "$interactive" = true ]; then
        # 交互式模式
        log_info "启动交互式容器..."
        docker run -it --rm \
            --name "$container_name" \
            -v "$(pwd):/home/testuser/.dotfiles:ro" \
            "dotfiles-test-$distro" \
            /bin/bash
    else
        # 自动测试模式
        docker run --rm \
            --name "$container_name" \
            -v "$(pwd):/home/testuser/.dotfiles:ro" \
            "dotfiles-test-$distro" \
            /bin/bash -c '
                set -e
                echo "==> 复制 dotfiles 到用户目录..."
                cp -r ~/.dotfiles ~/.dotfiles-test
                cd ~/.dotfiles-test

                echo "==> 检测操作系统..."
                bash scripts/detect_os.sh

                echo "==> 测试配置加载..."
                # 创建符号链接
                ln -sf ~/.dotfiles-test/common/.bashrc ~/.bashrc

                # 测试加载
                export DOTFILES_DIR=~/.dotfiles-test
                source ~/.bashrc

                echo "==> 测试别名..."
                type ll &> /dev/null && echo "✓ 别名 ll 可用"
                type gs &> /dev/null && echo "✓ 别名 gs 可用"

                echo "==> 测试函数..."
                type extract &> /dev/null && echo "✓ 函数 extract 可用"

                echo ""
                echo "==> 测试完成！"
            '

        if [ $? -eq 0 ]; then
            log_success "$distro 测试通过"
            return 0
        else
            log_error "$distro 测试失败"
            return 1
        fi
    fi
}

# 清理容器和镜像
cleanup() {
    log_info "清理测试容器和镜像..."

    # 停止并删除容器
    docker ps -a | grep "dotfiles-test-" | awk '{print $1}' | xargs -r docker rm -f

    # 删除镜像
    for distro in "${DISTROS[@]}"; do
        if docker image inspect "dotfiles-test-$distro" &> /dev/null; then
            docker rmi "dotfiles-test-$distro"
            log_success "已删除 $distro 镜像"
        fi
    done

    log_success "清理完成"
}

# 主函数
main() {
    local build_flag=false
    local clean_flag=false
    local all_flag=false
    local interactive_flag=false
    local distro=""

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -a|--all)
                all_flag=true
                shift
                ;;
            -b|--build)
                build_flag=true
                shift
                ;;
            -c|--clean)
                clean_flag=true
                shift
                ;;
            -i|--interactive)
                interactive_flag=true
                shift
                ;;
            arch|ubuntu|debian|fedora)
                distro=$1
                shift
                ;;
            *)
                log_error "未知选项: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # 检查 Docker 是否安装
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    # 执行清理
    if [ "$clean_flag" = true ]; then
        cleanup
        exit 0
    fi

    # 测试所有发行版
    if [ "$all_flag" = true ]; then
        local failed=0
        for d in "${DISTROS[@]}"; do
            if [ "$build_flag" = true ]; then
                build_image "$d"
            fi
            if ! run_test "$d" false; then
                ((failed++))
            fi
            echo ""
        done

        echo ""
        if [ $failed -eq 0 ]; then
            log_success "所有测试通过！"
        else
            log_error "$failed 个测试失败"
            exit 1
        fi
        exit 0
    fi

    # 测试单个发行版
    if [ -n "$distro" ]; then
        if [ "$build_flag" = true ]; then
            build_image "$distro"
        fi
        run_test "$distro" "$interactive_flag"
        exit 0
    fi

    # 没有指定发行版
    log_error "请指定要测试的发行版或使用 -a 测试所有"
    show_usage
    exit 1
}

main "$@"
