#
# ~/.bashrc
#

# 如果不是交互式 shell，不执行任何操作
[[ $- != *i* ]] && return

# 加载共享 shell 配置
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
if [ -f "$DOTFILES_DIR/common/shell/loader.sh" ]; then
    DOTFILES_LOAD_PROFILE=1 DOTFILES_LOAD_RUNTIME_EXTRAS=1
    source "$DOTFILES_DIR/common/shell/loader.sh"
    unset DOTFILES_LOAD_PROFILE DOTFILES_LOAD_RUNTIME_EXTRAS
fi

# 基础提示符（可以在发行版配置中覆盖）
PS1='[\u@\h \W]\$ '
