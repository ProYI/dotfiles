#
# ~/.bashrc
#

# 如果不是交互式 shell，不执行任何操作
[[ $- != *i* ]] && return

# Dotfiles 目录
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# 1. 加载通用配置（所有系统）
if [ -f "$DOTFILES_DIR/common/shell/exports.sh" ]; then
    source "$DOTFILES_DIR/common/shell/exports.sh"
fi

if [ -f "$DOTFILES_DIR/common/shell/aliases.sh" ]; then
    source "$DOTFILES_DIR/common/shell/aliases.sh"
fi

if [ -f "$DOTFILES_DIR/common/shell/functions.sh" ]; then
    source "$DOTFILES_DIR/common/shell/functions.sh"
fi

# 2. 加载 Linux 通用配置
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f "$DOTFILES_DIR/linux/shell/exports.sh" ]; then
        source "$DOTFILES_DIR/linux/shell/exports.sh"
    fi

    if [ -f "$DOTFILES_DIR/linux/shell/aliases.sh" ]; then
        source "$DOTFILES_DIR/linux/shell/aliases.sh"
    fi
fi

# 3. 加载发行版特定配置
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_CONFIG="$DOTFILES_DIR/distros/${ID}/shell/${ID}.sh"
    if [ -f "$DISTRO_CONFIG" ]; then
        source "$DISTRO_CONFIG"
    fi
fi

# 4. 检测 WSL（叠加在发行版配置之上）
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null 2>&1; then
    if [ -f "$DOTFILES_DIR/wsl/shell/wsl.sh" ]; then
        source "$DOTFILES_DIR/wsl/shell/wsl.sh"
    fi
fi

# 5. 加载 macOS 配置
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f "$DOTFILES_DIR/macos/shell/macos.sh" ]; then
        source "$DOTFILES_DIR/macos/shell/macos.sh"
    fi
fi

# 6. 加载 .profile（如果存在）
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
fi

# 7. Cargo 环境（如果安装了 Rust）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 8. Docker 镜像加速辅助函数
if [ -f "$HOME/.docker/functions.sh" ]; then
    source "$HOME/.docker/functions.sh"
fi

# 9. 可插拔开发工具模块
# 通过 DOTFILES_MODULES 环境变量控制加载哪些模块
# 示例: export DOTFILES_MODULES="node java python docker"
# 留空则加载所有可用模块
_load_modules() {
    local modules_dir="$DOTFILES_DIR/modules"
    local modules_to_load="${DOTFILES_MODULES:-}"

    if [ ! -d "$modules_dir" ]; then
        return
    fi

    if [ -z "$modules_to_load" ]; then
        # 默认加载所有模块
        for mod_dir in "$modules_dir"/*/; do
            [ -d "$mod_dir" ] || continue
            local mod_name
            mod_name="$(basename "$mod_dir")"
            # 跳过示例模板
            [[ "$mod_name" == _example ]] && continue

            local env_file="$mod_dir/shell/env.sh"
            if [ -f "$env_file" ]; then
                source "$env_file"
            fi
        done
    else
        # 按列表加载指定模块
        for mod_name in $modules_to_load; do
            local env_file="$modules_dir/$mod_name/shell/env.sh"
            if [ -f "$env_file" ]; then
                source "$env_file"
            else
                echo "[dotfiles] 警告: 模块 $mod_name 的 env.sh 不存在" >&2
            fi
        done
    fi
}
_load_modules
unset -f _load_modules

# 基础提示符（可以在发行版配置中覆盖）
PS1='[\u@\h \W]\$ '
