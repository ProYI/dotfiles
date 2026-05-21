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
