# 字体

终端图标和 Powerlevel10k 主题通常需要 Nerd Font。中文显示建议安装 CJK 回退字体。

## Nerd Font

推荐 JetBrains Mono Nerd Font 或 MesloLGS NF。

Linux 用户目录安装位置：

```bash
mkdir -p ~/.local/share/fonts
# 将下载并解压后的 *.ttf 或 *.otf 放入 ~/.local/share/fonts
fc-cache -fv
```

macOS 用户目录安装位置：

```bash
mkdir -p ~/Library/Fonts
# 将字体文件复制到 ~/Library/Fonts
```

## CJK 字体

Ubuntu / Debian：

```bash
sudo apt install -y fonts-noto-cjk
```

Arch / Manjaro：

```bash
sudo pacman -S --needed noto-fonts-cjk
```

Fedora：

```bash
sudo dnf install -y google-noto-sans-cjk-fonts
```

安装后在终端配置中选择 Nerd Font，并把 CJK 字体作为 fallback。
