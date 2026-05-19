#
# ~/.bashrc
#

# 如果不是交互式 shell，不执行任何操作
[[ $- != *i* ]] && return

# Dotfiles 目录
export DOTFILES_DIR="$HOME/.dotfiles"

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

# 基础提示符（可以在发行版配置中覆盖）
PS1='[\u@\h \W]\$ '
