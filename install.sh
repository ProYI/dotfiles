#!/bin/bash
# Dotfiles 主安装脚本

set -e

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Dotfiles 目录
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

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

SKIP_RECORDS=()

record_skip() {
    local message="$1"
    SKIP_RECORDS+=("$message")
    log_warning "跳过: $message"
}

command_exists() {
    command -v "$1" &> /dev/null
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
# 交互式包/模块选择系统
# ============================================================

# 解析 config/packages.conf，填充数组
# PACKAGES_BY_CATEGORY: 关联数组 category->包列表（空格分隔）
# MODULES_BY_CATEGORY:  关联数组 category->模块列表（空格分隔）
# ALL_CATEGORIES:       分类列表（空格分隔）
# PACKAGE_ORDER:        包在UI中的顺序（每行 category item label）
declare -A PACKAGES_BY_CATEGORY
declare -A MODULES_BY_CATEGORY
ALL_CATEGORIES=()
PACKAGE_ORDER=()

parse_package_conf() {
    local conf_file="$DOTFILES_DIR/config/packages.conf"
    if [ ! -f "$conf_file" ]; then
        log_error "配置文件不存在: $conf_file"
        return 1
    fi

    local current_category="基础"

    while IFS= read -r line; do
        # 跳过空行
        [[ -z "$line" ]] && continue

        # 跳过配置说明注释
        [[ "$line" =~ ^#.*格式 ]] && continue
        [[ "$line" =~ ^#.*分类说明 ]] && continue

        # 分类标题行: # ==================== 基础（必装，不可跳过） ====================
        if [[ "$line" =~ ^#[[:space:]]*(=+) ]]; then
            # 去掉所有 === 得到标题文字
            local title=$(echo "$line" | sed 's/^#[[:space:]]*//; s/[[:space:]]*=*//g')
            # 取第一个中文括号前的内容作为分类名
            local raw_category
            if [[ "$title" == *"（"* ]] || [[ "$title" == *"("* ]]; then
                raw_category=$(echo "$title" | sed 's/[（(].*//' | sed 's/[[:space:]]*$//')
            else
                raw_category="$title"
            fi
            current_category="$raw_category"
            # 记录分类（去重）
            if [[ "$current_category" != "基础" ]]; then
                local found=false
                for c in "${ALL_CATEGORIES[@]}"; do
                    [[ "$c" == "$current_category" ]] && found=true && break
                done
                $found || ALL_CATEGORIES+=("$current_category")
            fi
            continue
        fi

        # 跳过其他注释
        [[ "$line" =~ ^# ]] && continue

        # 包:格式
        local first
        first=$(echo "$line" | cut -d':' -f1 | sed 's/[[:space:]]//g')

        case "$first" in
            包)
                local pkg_name
                pkg_name=$(echo "$line" | cut -d':' -f2 | sed 's/[[:space:]]//g')
                PACKAGES_BY_CATEGORY["$current_category"]="${PACKAGES_BY_CATEGORY[$current_category]:-} $pkg_name"
                ;;
            模块)
                local mod_name mod_category
                mod_name=$(echo "$line" | cut -d':' -f2 | sed 's/[[:space:]]//g')
                mod_category=$(echo "$line" | cut -d':' -f3 | sed 's/[[:space:]]//g')
                MODULES_BY_CATEGORY["$mod_category"]="${MODULES_BY_CATEGORY[$mod_category]:-} $mod_name"
                # 确保模块所属分类被记录
                local found=false
                for c in "${ALL_CATEGORIES[@]}"; do
                    [[ "$c" == "$mod_category" ]] && found=true && break
                done
                $found || ALL_CATEGORIES+=("$mod_category")
                ;;
        esac
    done < "$conf_file"
}

# 交互式选择：展示所有分类，用户逐个勾选
# 设置 SELECTED_PACKAGES 和 SELECTED_MODULES 数组
SELECTED_PACKAGES=()
SELECTED_MODULES=()

select_packages_interactive() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     软件包和模块选择                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""

    # 显示基础包（必装）
    echo -e "${GREEN}📦 基础（必装）${NC}"
    for pkg in ${PACKAGES_BY_CATEGORY["基础"]:-}; do
        echo -e "  ${GREEN}[✓]${NC} $pkg"
        SELECTED_PACKAGES+=("$pkg")
    done
    echo ""

    # 构建 flat list: 每个条目格式 "category::type::name"
    local -a entries=()

    local modules_category="可插拔模块"

    for category in "${ALL_CATEGORIES[@]}"; do
        [[ "$category" == "基础" || "$category" == "模块" ]] && continue

        for pkg in ${PACKAGES_BY_CATEGORY[$category]:-}; do
            entries+=("$category::pkg::$pkg")
        done
        for mod in ${MODULES_BY_CATEGORY[$category]:-}; do
            entries+=("$modules_category::mod::$mod")
        done
    done

    # 默认全选；交互中通过切换改为 [x]/[ ] 样式
    local -a selected_flags=()
    local idx
    for ((idx=0; idx<${#entries[@]}; idx++)); do
        selected_flags[idx]=1
    done

    while true; do
        local global_idx=0
        local -a display_categories=()
        local -a display_to_entry_idx=()
        for category in "${ALL_CATEGORIES[@]}"; do
            [[ "$category" == "基础" || "$category" == "模块" ]] && continue
            display_categories+=("$category")
        done
        display_categories+=("$modules_category")

        for category in "${display_categories[@]}"; do

            local emoji=""
            case "$category" in
                开发工具) emoji="🔧" ;;
                系统工具) emoji="💻" ;;
                字体)     emoji="🔤" ;;
                浏览器)   emoji="🌐" ;;
                可插拔模块) emoji="🧩" ;;
                *)        emoji="📦" ;;
            esac

            echo -e "${emoji} ${category}"

            local -a cat_items=()
            local -a cat_item_indexes=()
            for ent_i in "${!entries[@]}"; do
                local ent="${entries[$ent_i]}"
                local ent_cat="${ent%%::*}"
                if [[ "$ent_cat" == "$category" ]]; then
                    cat_items+=("$ent")
                    cat_item_indexes+=("$ent_i")
                fi
            done

            local total=${#cat_items[@]}
            for ((i=0; i<total; i++)); do
                global_idx=$((global_idx + 1))
                local ent="${cat_items[$i]}"
                local rest="${ent#*::}"
                local ent_type="${rest%%::*}"
                local ent_name="${rest#*::}"
                local display_name="$ent_name"
                [[ "$ent_type" == "mod" ]] && display_name="[$ent_name]"
                local real_idx="${cat_item_indexes[$i]}"
                display_to_entry_idx[$global_idx]="$real_idx"
                local mark="[ ]"
                [[ "${selected_flags[$real_idx]}" == "1" ]] && mark="${GREEN}[✓]${NC}"
                printf "  %b [%s] %-16s" "$mark" "$global_idx" "$display_name"
                if (( (global_idx % 2 == 0) || i + 1 == total )); then echo ""; fi
            done
            echo ""
            echo ""
        done

        echo "输入编号/范围切换选择（如 3 8-12），a=全选，n=全不选，回车或 q=确认："
        read -r reply

        if [[ -z "$reply" || "$reply" == "q" ]]; then
            break
        fi

        if [[ "$reply" == "a" ]]; then
            for ((idx=0; idx<${#entries[@]}; idx++)); do
                selected_flags[idx]=1
            done
            echo ""
            continue
        fi

        if [[ "$reply" == "n" ]]; then
            for ((idx=0; idx<${#entries[@]}; idx++)); do
                selected_flags[idx]=0
            done
            echo ""
            continue
        fi

        for token in $reply; do
            if [[ "$token" == *-* ]]; then
                local start_num="${token%%-*}"
                local end_num="${token#*-}"
                if [[ "$start_num" =~ ^[0-9]+$ && "$end_num" =~ ^[0-9]+$ ]]; then
                    local n
                    for ((n=start_num; n<=end_num; n++)); do
                        if ((n >= 1 && n <= global_idx)); then
                            local flag_idx="${display_to_entry_idx[$n]}"
                            [[ -z "$flag_idx" ]] && continue
                            if [[ "${selected_flags[$flag_idx]}" == "1" ]]; then
                                selected_flags[$flag_idx]=0
                            else
                                selected_flags[$flag_idx]=1
                            fi
                        fi
                    done
                fi
            else
                if [[ "$token" =~ ^[0-9]+$ ]]; then
                    local num="$token"
                    if ((num >= 1 && num <= global_idx)); then
                        local flag_idx="${display_to_entry_idx[$num]}"
                        [[ -z "$flag_idx" ]] && continue
                        if [[ "${selected_flags[$flag_idx]}" == "1" ]]; then
                            selected_flags[$flag_idx]=0
                        else
                            selected_flags[$flag_idx]=1
                        fi
                    fi
                fi
            fi
        done
        echo ""
    done

    for ent_i in "${!entries[@]}"; do
        if [[ "${selected_flags[$ent_i]}" != "1" ]]; then
            continue
        fi
        local ent="${entries[$ent_i]}"
        local rest="${ent#*::}"
        local ent_type="${rest%%::*}"
        local ent_name="${rest#*::}"
        [[ "$ent_type" == "pkg" ]] && SELECTED_PACKAGES+=("$ent_name")
        [[ "$ent_type" == "mod" ]] && SELECTED_MODULES+=("$ent_name")
    done

    echo ""
    if [ ${#SELECTED_PACKAGES[@]} -eq 0 ] && [ ${#SELECTED_MODULES[@]} -eq 0 ]; then
        log_warning "未选择任何包"
    else
        log_info "已选择 ${#SELECTED_PACKAGES[@]} 个包、${#SELECTED_MODULES[@]} 个模块"
    fi
}

# 按命令行参数选择（非交互）
select_packages_arg() {
    local selected_categories="$1"

    for cat in $selected_categories; do
        case "$cat" in
            基础)
                for pkg in ${PACKAGES_BY_CATEGORY["基础"]:-}; do
                    SELECTED_PACKAGES+=("$pkg")
                done
                ;;
            *)
                for pkg in ${PACKAGES_BY_CATEGORY[$cat]:-}; do
                    SELECTED_PACKAGES+=("$pkg")
                done
                for mod in ${MODULES_BY_CATEGORY[$cat]:-}; do
                    SELECTED_MODULES+=("$mod")
                done
                ;;
        esac
    done

    log_info "已选择 ${#SELECTED_PACKAGES[@]} 个包、${#SELECTED_MODULES[@]} 个模块"
}

select_all_packages() {
    for category in "${ALL_CATEGORIES[@]}"; do
        [[ "$category" == "基础" || "$category" == "模块" ]] && continue
        for pkg in ${PACKAGES_BY_CATEGORY[$category]:-}; do
            SELECTED_PACKAGES+=("$pkg")
        done
        for mod in ${MODULES_BY_CATEGORY[$category]:-}; do
            SELECTED_MODULES+=("$mod")
        done
    done
    log_info "已选择全部 ${#SELECTED_PACKAGES[@]} 个包、${#SELECTED_MODULES[@]} 个模块"
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

    # 检测 WSL
    if detect_wsl; then
        log_info "检测到 WSL 环境"
    fi

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
    parse_package_conf

    # 选择模式
    if [[ -n "$PACKAGES_ARG" ]]; then
        select_packages_arg "$PACKAGES_ARG"
    elif [ "$SELECT_ALL" = true ]; then
        select_all_packages
    elif [[ -n "$MODULES_ARG" ]]; then
        # 只指定了 --modules，包仍然交互式选择
        select_packages_interactive
    else
        select_packages_interactive
    fi

    # 4. 创建符号链接（共通配置）
    create_symlinks

    # 5. 根据操作系统执行特定安装（包安装 + 系统配置）
    #    将 SELECTED_PACKAGES 导出为逗号分隔字符串，供 distro 脚本使用
    export DOTFILES_SELECTED_PACKAGES="$(IFS=,; echo "${SELECTED_PACKAGES[*]}")"

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
