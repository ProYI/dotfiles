# ~/.zshrc - Zsh 配置

# === 历史管理 ===
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
# 允许多个 zsh 实例共享历史
setopt SHARE_HISTORY
# 每条命令立即写入历史文件
setopt INC_APPEND_HISTORY
# 防止历史被覆盖
setopt APPEND_HISTORY
# 去重
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS

# === 通用配置（与 .bashrc 保持一致）===

# 加载通用环境变量
if [ -f "$HOME/.dotfiles/common/shell/exports.sh" ]; then
    source "$HOME/.dotfiles/common/shell/exports.sh"
fi

# 加载通用别名
if [ -f "$HOME/.dotfiles/common/shell/aliases.sh" ]; then
    source "$HOME/.dotfiles/common/shell/aliases.sh"
fi

# 加载通用函数
if [ -f "$HOME/.dotfiles/common/shell/functions.sh" ]; then
    source "$HOME/.dotfiles/common/shell/functions.sh"
fi

# 加载 Linux 通用配置
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f "$HOME/.dotfiles/linux/shell/exports.sh" ]; then
        source "$HOME/.dotfiles/linux/shell/exports.sh"
    fi
    if [ -f "$HOME/.dotfiles/linux/shell/aliases.sh" ]; then
        source "$HOME/.dotfiles/linux/shell/aliases.sh"
    fi
fi

# 加载发行版特定配置
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_CONFIG="$HOME/.dotfiles/distros/${ID}/shell/${ID}.sh"
    if [ -f "$DISTRO_CONFIG" ]; then
        source "$DISTRO_CONFIG"
    fi
fi

# 检测 WSL（叠加在发行版配置之上）
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null 2>&1; then
    if [ -f "$HOME/.dotfiles/wsl/shell/wsl.sh" ]; then
        source "$HOME/.dotfiles/wsl/shell/wsl.sh"
    fi
fi

# 重载别名：reload 指向 .zshrc
alias reload='source ~/.zshrc'

# === Zinit 初始化 ===
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# === Zinit 插件管线 ===
# 主题
zinit light romkatv/powerlevel10k

# 语法高亮 & 自动建议
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions

# 工具
zinit light joshskidmore/zsh-fzf-tab-completion

# 加载 zsh 专属别名
if [ -f "$HOME/.dotfiles/common/shell/zsh-aliases.sh" ]; then
    source "$HOME/.dotfiles/common/shell/zsh-aliases.sh"
fi

# 如果 .zshrc.local 存在，加载私有配置
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
