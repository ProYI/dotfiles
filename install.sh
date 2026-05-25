#!/bin/bash
# Dotfiles 主安装脚本

set -e

# Dotfiles 目录
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/common.sh"
# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib/packages.sh"

SKIP_RECORDS=()

record_skip() {
    local message="$1"
    SKIP_RECORDS+=("$message")
    log_warning "跳过: $message"
}

# 加载系统检测脚本
source "$DOTFILES_DIR/scripts/detect_os.sh"

# 显示欢迎信息
show_banner() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║     Dotfiles 安装脚本                 ║"
    echo "║     多系统配置管理                    ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
}

# 备份现有配置
backup_existing() {
    log_info "备份现有配置..."
    bash "$DOTFILES_DIR/scripts/backup.sh"
}

# 创建符号链接
create_symlinks() {
    log_info "创建符号链接..."

    # 链接 .bashrc
    if [ -f "$DOTFILES_DIR/common/.bashrc" ]; then
        ln -sf "$DOTFILES_DIR/common/.bashrc" "$HOME/.bashrc"
        log_success "已链接 .bashrc"
    fi

    # 链接 .zshrc。旧机器已有 zsh 时保留原有启动配置。
    if [ -f "$DOTFILES_DIR/common/.zshrc" ]; then
        if command_exists zsh && [ ! "$HOME/.zshrc" -ef "$DOTFILES_DIR/common/.zshrc" ]; then
            record_skip "检测到已有 zsh，保留 $HOME/.zshrc"
        else
            ln -sf "$DOTFILES_DIR/common/.zshrc" "$HOME/.zshrc"
            log_success "已链接 .zshrc"
        fi
    fi

    # 链接 .profile
    if [ -f "$DOTFILES_DIR/common/.profile" ]; then
        ln -sf "$DOTFILES_DIR/common/.profile" "$HOME/.profile"
        log_success "已链接 .profile"
    fi

    # 运行通用链接脚本
    bash "$DOTFILES_DIR/scripts/link.sh"
}

# 安装发行版特定配置
install_distro_specific() {
    local distro="$1"
    local install_script="$DOTFILES_DIR/distros/$distro/install.sh"

    if [ -f "$install_script" ]; then
        log_info "运行 $distro 特定安装脚本..."
        bash "$install_script"
    else
        log_warning "未找到 $distro 的安装脚本"
    fi
}

# ============================================================
# 模块安装（按选择的模块列表）
# ============================================================

install_modules() {
    local modules_to_install="${1:-}"

    if [ -z "$modules_to_install" ]; then
        return
    fi

    local modules_dir="$DOTFILES_DIR/modules"
    if [ ! -d "$modules_dir" ]; then
        log_warning "模块目录不存在: $modules_dir"
        return
    fi

    for mod_name in $modules_to_install; do
        local mod_install="$modules_dir/$mod_name/install.sh"

        # 检查是否已安装
        local cmds=()
        case "$mod_name" in
            node)  cmds=(fnm node npm) ;;
            java)  cmds=(java java sdk javac) ;;
            docker) cmds=(docker docker docker-compose) ;;
            python) cmds=(python3 pip3 python) ;;
            rust)  cmds=(rust cargo rustup rust) ;;
            eza)   cmds=(eza) ;;
            *)     cmds=() ;;
        esac

        for cmd in "${cmds[@]}"; do
            if command_exists "$cmd"; then
                record_skip "检测到已有 ${mod_name}，保留 ${mod_name} 模块"
                continue 2
            fi
        done

        if [ -f "$mod_install" ]; then
            log_info "安装模块: $mod_name"
            bash "$mod_install"
        else
            log_warning "模块 $mod_name 的安装脚本不存在: $mod_install"
        fi
    done
}

# 配置镜像源
setup_mirrors() {
    log_info "配置国内镜像源..."
    if [ -f "$DOTFILES_DIR/scripts/setup_mirrors.sh" ]; then
        bash "$DOTFILES_DIR/scripts/setup_mirrors.sh"
    else
        log_warning "未找到镜像源配置脚本，跳过"
    fi
}

run_doctor() {
    local doctor_script="$DOTFILES_DIR/scripts/doctor.sh"

    if [ -x "$doctor_script" ]; then
        log_info "运行安装验收检查..."
        bash "$doctor_script" all
    else
        log_warning "未找到验收脚本，跳过: $doctor_script"
    fi
}

show_skip_records() {
    if [ "${#SKIP_RECORDS[@]}" -eq 0 ]; then
        return
    fi

    echo ""
    log_info "跳过记录:"
    for record in "${SKIP_RECORDS[@]}"; do
        echo "  - $record"
    done
}

# 解析命令行参数
parse_args() {
    SKIP_MIRRORS=false
    SKIP_BACKUP=false
    SELECT_ALL=false
    PACKAGES_ARG=""
    MODULES_ARG=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skip-mirrors)
                SKIP_MIRRORS=true
                shift
                ;;
            --skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --all)
                SELECT_ALL=true
                shift
                ;;
            --packages)
                if [[ -z "${2:-}" ]]; then
                    log_error "--packages 需要指定分类列表（空格分隔）"
                    exit 1
                fi
                PACKAGES_ARG="$2"
                shift 2
                ;;
            --modules)
                if [[ -z "${2:-}" ]]; then
                    MODULES_ARG=""
                    shift
                elif [[ "${2:0:1}" == "-" ]]; then
                    MODULES_ARG=""
                    shift
                else
                    MODULES_ARG="$2"
                    shift 2
                fi
                ;;
            *)
                log_error "未知参数: $1"
                echo "用法: $0 [--skip-mirrors] [--skip-backup] [--all] [--packages \"分类1 分类2\"] [--modules \"模块1 模块2\"]"
                exit 1
                ;;
        esac
    done
}

# 加载用户配置
load_user_config() {
    local config_file="${DOTFILES_DIR}/config/dotfiles.conf"
    if [ -f "$config_file" ]; then
        # 只加载不覆盖 DOTFILES_DIR
        local saved_dir="$DOTFILES_DIR"
        source "$config_file"
        DOTFILES_DIR="$saved_dir"
    fi
}

# 主安装流程
main() {
    show_banner

    # 解析命令行参数
    parse_args "$@"

    # 加载用户配置（在 parse_args 之后，避免 DOTFILES_DIR 未定义）
    load_user_config

    # 检测操作系统
    OS=$(detect_os)
    log_info "检测到操作系统: $OS"

    # 1. 镜像源配置
    echo ""
    if [ "$SKIP_MIRRORS" = true ]; then
        record_skip "跳过镜像源配置 (--skip-mirrors)"
    else
        read -p "是否配置国内镜像源？(推荐) (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            setup_mirrors
        fi
    fi

    # 2. 备份现有配置
    echo ""
    if [ "$SKIP_BACKUP" = true ]; then
        record_skip "跳过配置备份 (--skip-backup)"
    else
        read -p "是否备份现有配置？(y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            backup_existing
        fi
    fi

    # 3. 软件包和模块选择（核心改动）
    echo ""
    log_info "开始软件包和模块选择..."

    # 解析 packages.conf
    dotfiles_parse_package_conf

    # 选择模式
    if [[ -n "$PACKAGES_ARG" ]]; then
        dotfiles_select_packages_arg "$PACKAGES_ARG"
    elif [ "$SELECT_ALL" = true ]; then
        dotfiles_select_all_packages
    elif [[ -n "$MODULES_ARG" ]]; then
        # 只指定了 --modules，包仍然交互式选择
        dotfiles_select_packages_interactive
    else
        dotfiles_select_packages_interactive
    fi

    # 4. 创建符号链接（共通配置）
    create_symlinks

    # 5. 根据操作系统执行特定安装（包安装 + 系统配置）
    #    将选择结果导出为逗号分隔字符串，供 distro 脚本和 doctor 使用
    export DOTFILES_SELECTED_PACKAGES="$(IFS=,; echo "${SELECTED_PACKAGES[*]}")"
    export DOTFILES_SELECTED_MODULES="$(IFS=,; echo "${SELECTED_MODULES[*]}")"

    case "$OS" in
        arch)
            install_distro_specific "arch"
            ;;
        ubuntu)
            install_distro_specific "ubuntu"
            ;;
        debian)
            install_distro_specific "debian"
            ;;
        fedora)
            install_distro_specific "fedora"
            ;;
        manjaro)
            install_distro_specific "manjaro"
            ;;
        macos)
            log_info "macOS 配置..."
            ;;
        *)
            log_warning "未知的操作系统: $OS"
            log_info "仅安装通用配置"
            ;;
    esac

    # 6. 安装选中的模块
    if [ ${#SELECTED_MODULES[@]} -gt 0 ]; then
        install_modules "$(IFS=' '; echo "${SELECTED_MODULES[*]}")"
    fi

    # 7. 输出明确的安装/配置可用性摘要
    run_doctor

    show_skip_records

    echo ""
    log_success "安装完成！"
    echo ""
    log_info "请运行以下命令使配置生效:"
    echo "  source ~/.bashrc"
    echo ""
    log_info "或者重新登录系统"
}

# 运行主函数
main "$@"
