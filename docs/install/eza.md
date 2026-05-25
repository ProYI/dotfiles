# eza

eza 是现代 ls 替代工具。部分发行版仓库里没有最新版本，所以不放入默认基础包。

## Arch / Manjaro

```bash
sudo pacman -S --needed eza
```

## Fedora

```bash
sudo dnf install -y eza
```

## Ubuntu / Debian

先尝试系统仓库：

```bash
sudo apt update
sudo apt install -y eza
```

如果仓库没有 eza，可选择官方源、cargo 或预编译包。不要在主安装脚本中自动添加第三方源，避免影响系统包管理策略。

## alias

如果已安装 eza，可以在 `common/shell/aliases.sh` 或私有配置里加：

```bash
alias ls='eza --icons=auto'
alias ll='eza -lah --icons=auto --git'
```
