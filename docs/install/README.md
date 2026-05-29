# 软件安装

主安装脚本只负责镜像源、基础包和 dotfiles 链接。下面这些软件需要按需手动安装。

## 日常软件

| 软件 | 说明 |
|------|------|
| [WPS Office](#wps-office) | 办公套件，兼容 MS Office 格式 |
| [VLC](#vlc) | 万能媒体播放器 |
| [Flameshot](#flameshot) | 截图标注工具 |

### WPS Office

**Ubuntu / Debian**

从 [WPS 官网](https://www.wps.cn/product/wpslinux) 下载 `.deb` 包安装。

**Arch / Manjaro**

```bash
yay -S wps-office-cn
```

### VLC

**Ubuntu / Debian**

```bash
sudo apt install vlc
```

**Arch / Manjaro**

```bash
sudo pacman -S vlc
```

**Fedora**

```bash
sudo dnf install vlc
```

### Flameshot

**Ubuntu / Debian**

```bash
sudo apt install flameshot
```

**Arch / Manjaro**

```bash
sudo pacman -S flameshot
```

**Fedora**

```bash
sudo dnf install flameshot
```

## 终端软件

| 软件 | 说明 |
|------|------|
| [Ghostty](#ghostty) | GPU 加速终端模拟器 |
| [zoxide](#zoxide) | 智能目录跳转，替代 cd |
| [fzf-tab](#fzf-tab) | zsh 的 fzf 风格 Tab 补全 |
| [eza](eza.md) | 现代 ls 替代品，支持图标和 Git 状态 |
| [htop](#htop) | 交互式进程查看器 |
| [tmux](https://github.com/tmux/tmux) | 终端复用器（base 包，通常已安装） |

### Ghostty

**Ubuntu / Debian**

从 [Ghostty 官网](https://ghostty.org) 下载 `.deb` 包。

**Arch / Manjaro**

```bash
sudo pacman -S ghostty
```

**Fedora**

从 [Ghostty 官网](https://ghostty.org) 下载 `.rpm` 包。

### zoxide

智能目录跳转工具，根据使用频率自动补全路径。安装后 `runtime.sh` 会自动检测并初始化。

**Ubuntu / Debian**

```bash
sudo apt install zoxide
```

**Arch / Manjaro**

```bash
sudo pacman -S zoxide
```

**Fedora**

```bash
sudo dnf install zoxide
```

### fzf-tab

zsh 的 fzf 风格 Tab 补全插件，需要通过 zsh 插件管理器安装：

```bash
# zinit
zinit light Aloxaf/fzf-tab

# oh-my-zsh
git clone https://github.com/Aloxaf/fzf-tab.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
```

### htop

**Ubuntu / Debian**

```bash
sudo apt install htop
```

**Arch / Manjaro**

```bash
sudo pacman -S htop
```

**Fedora**

```bash
sudo dnf install htop
```

## 即时通讯

| 软件 | 说明 |
|------|------|
| [Telegram](#telegram) | 即时通讯 |

### Telegram

**Ubuntu / Debian**

```bash
sudo apt install telegram-desktop
```

**Arch / Manjaro**

```bash
sudo pacman -S telegram-desktop
```

**Fedora**

```bash
sudo dnf install telegram-desktop
```

## 开发工具

| 软件 | 说明 | 文档 |
|------|------|------|
| Docker | 容器引擎 | [docker.md](docker.md) |
| Node / fnm | Node 版本管理 | [node.md](node.md) |
| Python | Python 环境管理 | [python.md](python.md) |
| Rust | 系统级编程语言 | [rust.md](rust.md) |
| Java / SDKMAN | JDK 版本管理 | [java.md](java.md) |

这些工具涉及版本管理、服务配置或系统级变更，详见各自文档。

## 浏览器

| 软件 | 说明 |
|------|------|
| [Firefox ESR](#firefox-esr) | 开源浏览器，长期支持版 |
| [Google Chrome](#google-chrome) | Chromium 内核浏览器 |

### Firefox ESR

长期支持版，适合开发环境。

**Ubuntu / Debian**

```bash
sudo apt install firefox-esr
```

**Arch / Manjaro**

```bash
sudo pacman -S firefox-esr
```

**Fedora**

```bash
sudo dnf install firefox-esr
```

### Google Chrome

从 [Chrome 官网](https://www.google.com/chrome/) 下载对应发行版的安装包。

**Arch / Manjaro**

```bash
yay -S google-chrome
```

## AI 软件

| 软件 | 说明 |
|------|------|
| [Claude Code](#claude-code) | Anthropic 官方 CLI 编码助手 |
| [Codex](#codex) | OpenAI 官方 CLI 编码助手 |
| [CC-Switch](#cc-switch) | Claude Code / Codex 多工具统一管理桌面端 |

两者均通过 npm 全局安装，需要先完成 [Node / fnm](node.md) 的安装。

### Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### Codex

```bash
npm install -g @openai/codex
```

### CC-Switch

跨平台桌面应用，统一管理 Claude Code、Codex、Gemini CLI 等 AI 编码工具的 API 提供商切换、MCP 配置、用量统计。[GitHub 仓库](https://github.com/farion1231/cc-switch)

**Ubuntu / Debian**

从 [Releases](https://github.com/farion1231/cc-switch/releases) 下载 `.deb` 包：

```bash
sudo apt install ./cc-switch_*.deb
```

**Arch / Manjaro**

```bash
paru -S cc-switch-bin
```

**Fedora**

从 [Releases](https://github.com/farion1231/cc-switch/releases) 下载 `.rpm` 包安装。

**macOS**

```bash
brew install --cask cc-switch
```
