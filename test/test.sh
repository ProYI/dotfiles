#!/bin/bash
# Docker 测试脚本 - 在容器中测试 dotfiles 安装

set -e

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 加载 Docker 镜像配置
DOCKER_MIRROR=""
if [ -f "$HOME/.docker/mirror.conf" ]; then
    source "$HOME/.docker/mirror.conf"
    if [ -n "$DOCKER_MIRROR" ]; then
        # 添加斜杠后缀
        DOCKER_MIRROR="${DOCKER_MIRROR}/"
        log_info() { echo -e "${BLUE}==>${NC} $1"; }
        log_info "使用 Docker 镜像加速: $DOCKER_MIRROR"
    fi
fi

log_info() {
    echo -e "${BLUE}==>${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

load_proxy_config() {
    local env_http_proxy="${DOTFILES_HTTP_PROXY:-}"
    local env_https_proxy="${DOTFILES_HTTPS_PROXY:-}"
    local env_no_proxy="${DOTFILES_NO_PROXY:-}"
    local env_fnm_node_dist_mirror="${FNM_NODE_DIST_MIRROR:-}"
    local proxy_config="${DOTFILES_PROXY_CONFIG:-config/proxy.conf}"

    if [ -f "$proxy_config" ]; then
        # shellcheck disable=SC1090
        source "$proxy_config"
    fi

    DOTFILES_HTTP_PROXY="${env_http_proxy:-${DOTFILES_HTTP_PROXY:-}}"
    DOTFILES_HTTPS_PROXY="${env_https_proxy:-${DOTFILES_HTTPS_PROXY:-}}"
    DOTFILES_NO_PROXY="${env_no_proxy:-${DOTFILES_NO_PROXY:-}}"
    FNM_NODE_DIST_MIRROR="${env_fnm_node_dist_mirror:-${FNM_NODE_DIST_MIRROR:-}}"
    export DOTFILES_HTTP_PROXY DOTFILES_HTTPS_PROXY DOTFILES_NO_PROXY FNM_NODE_DIST_MIRROR
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
  -k, --keep-image    测试后保留镜像（默认会清理）
  -s, --skip-test     跳过测试（首次安装后二次运行，验证跳过逻辑）

发行版:
  arch                测试 Arch Linux
  ubuntu              测试 Ubuntu
  debian              测试 Debian
  fedora              测试 Fedora

示例:
  $0 arch                    # 测试 Arch Linux（测试后删除镜像）
  $0 -k arch                 # 测试 Arch Linux（保留镜像）
  $0 -a                      # 测试所有发行版
  $0 -b ubuntu               # 重新构建并测试 Ubuntu
  $0 -i arch                 # 交互式进入 Arch 容器
  $0 -c                      # 清理所有测试容器和镜像
  $0 -s arch                 # 首次安装 + 二次运行，验证跳过逻辑
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

    # 如果本地已有基础镜像，跳过拉取加速，build 时也传空 DOCKER_MIRROR 避免 build 阶段拉加速
    local base_image=$(grep "^FROM" "$dockerfile" | awk '{print $2}' | sed 's/\${DOCKER_MIRROR}//')
    local build_mirror=""
    if docker image inspect "$base_image" &> /dev/null; then
        log_info "本地已有基础镜像: $base_image，跳过拉取"
    elif [ -n "$DOCKER_MIRROR" ]; then
        # 本地没有，才通过加速拉取
        # Docker Hub 官方镜像需要添加 library/ 前缀
        local mirror_image="$base_image"
        if [[ ! "$base_image" =~ / ]]; then
            mirror_image="library/$base_image"
        fi

        log_info "尝试拉取基础镜像: ${DOCKER_MIRROR}${mirror_image}"
        if docker pull "${DOCKER_MIRROR}${mirror_image}" 2>/dev/null; then
            docker tag "${DOCKER_MIRROR}${mirror_image}" "${base_image}"
            docker rmi "${DOCKER_MIRROR}${mirror_image}" &> /dev/null || true
            log_info "通过加速镜像拉取成功"
        else
            log_warning "加速镜像拉取失败，回退到 Docker Hub"
            docker pull "$base_image" 2>/dev/null || true
        fi
    fi

    docker build --build-arg DOCKER_MIRROR="$build_mirror" \
        -f "$dockerfile" -t "dotfiles-test-$distro" .

    log_success "$distro 镜像构建完成"
}

# 运行测试
run_test() {
    local distro=$1
    local interactive=$2
    local keep_image=${3:-false}

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
        docker run -d \
            --name "$container_name" \
            -e DOTFILES_HTTP_PROXY \
            -e DOTFILES_HTTPS_PROXY \
            -e DOTFILES_NO_PROXY \
            -e FNM_NODE_DIST_MIRROR \
            "dotfiles-test-$distro" \
            sleep infinity >/dev/null

        cleanup_interactive_container() {
            docker rm -f "$container_name" &> /dev/null || true
        }
        trap cleanup_interactive_container RETURN

        log_info "复制 dotfiles 到容器可写目录..."
        docker exec "$container_name" rm -rf /home/testuser/.dotfiles-test
        docker cp . "$container_name:/home/testuser/.dotfiles-test"
        docker exec -u root "$container_name" chown -R testuser:testuser /home/testuser/.dotfiles-test

        log_info "进入交互式 shell: /home/testuser/.dotfiles-test"
        docker exec -it \
            -e DOTFILES_HTTP_PROXY \
            -e DOTFILES_HTTPS_PROXY \
            -e DOTFILES_NO_PROXY \
            -e FNM_NODE_DIST_MIRROR \
            -w /home/testuser/.dotfiles-test \
            "$container_name" \
            /bin/bash
    else
        # 自动测试模式
        docker run --rm \
            --name "$container_name" \
            -e DOTFILES_HTTP_PROXY \
            -e DOTFILES_HTTPS_PROXY \
            -e DOTFILES_NO_PROXY \
            -e FNM_NODE_DIST_MIRROR \
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
                # 创建完整符号链接
                ln -sf ~/.dotfiles-test/common/.bashrc ~/.bashrc
                ln -sf ~/.dotfiles-test/common/.zshrc ~/.zshrc
                DOTFILES_DIR=~/.dotfiles-test bash ~/.dotfiles-test/scripts/link.sh

                # 测试加载
                export DOTFILES_DIR=~/.dotfiles-test
                source ~/.bashrc

                echo "==> 测试别名..."
                type ll &> /dev/null && echo "✓ 别名 ll 可用"
                type gs &> /dev/null && echo "✓ 别名 gs 可用"

                echo "==> 测试函数..."
                type extract &> /dev/null && echo "✓ 函数 extract 可用"

                echo "==> 安装发行版基础包..."
                if [ -f "/etc/os-release" ]; then
                    . /etc/os-release
                    distro_install="$HOME/.dotfiles-test/distros/${ID}/install.sh"
                    if [ -f "$distro_install" ]; then
                        bash "$distro_install"
                    else
                        echo "⚠ 未找到发行版安装脚本: $distro_install"
                    fi
                fi

                echo "==> 安装所有开发工具模块..."
                modules_dir="$HOME/.dotfiles-test/modules"
                failed_modules=()
                for mod_dir in "$modules_dir"/*/; do
                    [ -d "$mod_dir" ] || continue
                    mod_name="$(basename "$mod_dir")"
                    [[ "$mod_name" == _example ]] && continue
                    mod_install="$mod_dir/install.sh"
                    if [ -f "$mod_install" ]; then
                        echo "  安装模块: $mod_name"
                        if ! bash "$mod_install"; then
                            echo "  ⚠ 模块 $mod_name 安装失败"
                            failed_modules+=("$mod_name")
                        fi
                    fi
                done

                if [ ${#failed_modules[@]} -gt 0 ]; then
                    echo ""
                    echo "==> 失败模块: ${failed_modules[*]}"
                    exit 1
                fi

                echo ""
                echo "==> Dotfiles 验收检查..."
                bash "$HOME/.dotfiles-test/scripts/doctor.sh" all

                echo ""
                echo "==> 测试完成！"
            '

        local test_result=$?

        # 测试完成后清理镜像（除非指定保留）
        if [ "$keep_image" = false ] && [ $test_result -eq 0 ]; then
            log_info "清理测试镜像..."
            docker rmi "dotfiles-test-$distro" &> /dev/null || true
        fi

        if [ $test_result -eq 0 ]; then
            log_success "$distro 测试通过"
            return 0
        else
            log_error "$distro 测试失败"
            return 1
        fi
    fi
}

# 运行跳过测试：首次安装 + 二次运行
run_skip_test() {
    local distro=$1

    log_info "跳过测试 $distro..."

    # 检查镜像是否存在
    if ! docker image inspect "dotfiles-test-$distro" &> /dev/null; then
        log_info "镜像不存在，开始构建..."
        build_image "$distro"
    fi

    local container_name="dotfiles-test-$distro-skip-$(date +%s)"

    # 启动容器（不 --rm，保持运行）
    log_info "启动测试容器..."
    docker run -d \
        --name "$container_name" \
        -e DOTFILES_HTTP_PROXY \
        -e DOTFILES_HTTPS_PROXY \
        -e DOTFILES_NO_PROXY \
        -e FNM_NODE_DIST_MIRROR \
        -v "$(pwd):/home/testuser/.dotfiles:ro" \
        "dotfiles-test-$distro" \
        sleep infinity >/dev/null

    # 清理函数（容器 + 镜像）
    cleanup_skip_container() {
        docker rm -f "$container_name" &> /dev/null || true
        docker rmi "dotfiles-test-$distro" &> /dev/null || true
    }
    trap cleanup_skip_container RETURN

    log_info "=== 第一次安装（全量安装） ==="
    local first_output
    first_output=$(docker exec "$container_name" /bin/bash -c '
        echo "==> 复制 dotfiles 到用户目录..."
        cp -r ~/.dotfiles ~/.dotfiles-test
        cd ~/.dotfiles-test

        echo "==> 安装发行版基础包..."
        if [ -f "/etc/os-release" ]; then
            . /etc/os-release
            distro_install="$HOME/.dotfiles-test/distros/${ID}/install.sh"
            if [ -f "$distro_install" ]; then
                bash "$distro_install"
            fi
        fi

        echo "==> 安装所有开发工具模块..."
        modules_dir="$HOME/.dotfiles-test/modules"
        for mod_dir in "$modules_dir"/*/; do
            [ -d "$mod_dir" ] || continue
            mod_name="$(basename "$mod_dir")"
            [[ "$mod_name" == _example ]] && continue
            mod_install="$mod_dir/install.sh"
            if [ -f "$mod_install" ]; then
                echo "  安装模块: $mod_name"
                bash "$mod_install" || true
            fi
        done

        echo "==> 第一次安装完成"
    ' 2>&1)

    echo "$first_output"

    log_info "=== 第二次安装（验证跳过逻辑） ==="
    local second_output
    second_output=$(docker exec "$container_name" /bin/bash -c '
        cd ~/.dotfiles-test

        echo "==> 再次运行安装脚本（跳过镜像源和备份）..."
        export DOTFILES_DIR=~/.dotfiles-test
        source ~/.bashrc || true

        # 模拟 install.sh 的交互式流程：
        # 1) 镜像源 n, 2) 备份 n, 3) 模块 y, 4) 模块列表留空
        {
            echo "n"
            echo "n"
            echo "y"
            echo ""
        } | bash install.sh 2>&1 || true

        echo "==> 再次安装开发工具模块..."
        modules_dir="$HOME/.dotfiles-test/modules"
        for mod_dir in "$modules_dir"/*/; do
            [ -d "$mod_dir" ] || continue
            mod_name="$(basename "$mod_dir")"
            [[ "$mod_name" == _example ]] && continue
            mod_install="$mod_dir/install.sh"
            if [ -f "$mod_install" ]; then
                echo "  重新安装模块: $mod_name"
                bash "$mod_install" 2>&1 || true
            fi
        done

        echo "==> 第二次安装完成"
    ' 2>&1) || true

    echo "$second_output"

    # 分析跳过结果
    local skip_count=0
    local skip_modules=0
    local skip_packages=0

    # 统计模块跳过（从第二次输出的模块部分）
    skip_modules=$(echo "$second_output" | grep -c "检测到已有.*保留.*模块" 2>/dev/null || true)
    skip_packages=$(echo "$second_output" | grep -c "检测到已有.*不重新安装" 2>/dev/null || true)
    skip_count=$((skip_modules + skip_packages))

    echo ""
    log_info "=== 跳过统计 ==="
    log_info "模块跳过: $skip_modules 个"
    log_info "包跳过: $skip_packages 个"
    log_info "总计跳过: $skip_count 项"

    if [ "$skip_count" -gt 0 ]; then
        log_success "跳过测试通过：检测到 $skip_count 项已安装，正确跳过"
    else
        log_error "跳过测试失败：未检测到任何跳过记录"
        return 1
    fi

    return 0
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
    local keep_image_flag=false
    local skip_test_flag=false
    local distro=""

    load_proxy_config

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
            -k|--keep-image)
                keep_image_flag=true
                shift
                ;;
            -s|--skip-test)
                skip_test_flag=true
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
            if ! run_test "$d" false "$keep_image_flag"; then
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

    # 跳过测试模式：首次安装 + 二次运行，验证跳过逻辑
    if [ "$skip_test_flag" = true ]; then
        if [ -z "$distro" ]; then
            log_error "跳过测试模式需要指定发行版: $0 -s arch"
            show_usage
            exit 1
        fi

        if [ "$build_flag" = true ]; then
            build_image "$distro"
        fi
        run_skip_test "$distro"
        exit 0
    fi

    # 测试单个发行版
    if [ -n "$distro" ]; then
        if [ "$build_flag" = true ]; then
            build_image "$distro"
        fi
        run_test "$distro" "$interactive_flag" "$keep_image_flag"
        exit 0
    fi

    # 没有指定发行版
    log_error "请指定要测试的发行版或使用 -a 测试所有"
    show_usage
    exit 1
}

main "$@"
