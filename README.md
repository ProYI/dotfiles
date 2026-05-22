# Dotfiles - 多系统配置管理

一个支持多个操作系统和 Linux 发行版的配置文件管理方案。

## 特性

- ✅ **多系统支持**: Linux、macOS、Windows (WSL)
- ✅ **多发行版支持**: Arch、Ubuntu、Debian、Fedora、Manjaro 等
- ✅ **国内镜像源**: 自动配置阿里云、清华等国内镜像，大幅提升下载速度
- ✅ **分层配置**: 通用配置 → Linux 通用 → 发行版特定
- ✅ **自动检测**: 自动识别操作系统和发行版
- ✅ **符号链接管理**: 自动创建和管理配置文件链接
- ✅ **备份功能**: 安装前自动备份现有配置
- ✅ **zsh + Zinit**: 轻量高性能 zsh 插件管理
- ✅ **可插拔开发工具模块**: Node (fnm)、Java (sdkman)、Python (pyenv)、Docker、Rust
- ✅ **字体配置**: Nerd Font 检测 + 各终端 Wayland 字体配置
- ✅ **SSH 配置**: 安全模板 + 主机管理

## 目录结构

```
dotfiles/
├── common/                    # 所有系统通用配置
│   ├── shell/
│   │   ├── aliases.sh        # 通用别名
│   │   ├── functions.sh      # 通用函数
│   │   ├── exports.sh        # 通用环境变量
│   │   └── zsh-aliases.sh    # zsh 专属别名
│   ├── font/
│   │   └── nerd-font.sh      # Nerd Font 检测和安装
│   ├── .bashrc               # Bash 配置
│   ├── .zshrc                # Zsh 配置 (Zinit)
│   ├── .profile              # Shell profile
│   ├── .vimrc                # Vim 配置
│   ├── .gitconfig            # Git 配置
│   ├── .tmux.conf            # Tmux 配置
│   └── .ssh/                 # SSH 配置模板
│       └── config            # SSH 模板（复制到 ~/.ssh/config）
│
├── linux/                     # Linux 通用配置
│   ├── shell/
│   │   ├── aliases.sh        # Linux 通用别名
│   │   └── exports.sh        # Linux 通用环境变量
│   └── font/                  # 终端字体配置
│       ├── foot.conf         # Wayland 终端 foot
│       ├── kitty.conf        # Kitty 终端
│       ├── alacritty.toml    # Alacritty 终端
│       └── wezterm.lua       # WezTerm 终端
│
├── modules/                   # 可插拔开发工具模块
│   ├── _example/             # 模块模板
│   │   ├── install.sh
│   │   └── shell/env.sh
│   ├── node/                 # Node.js (fnm)
│   │   ├── install.sh
│   │   └── shell/env.sh
│   ├── java/                 # Java (sdkman)
│   │   ├── install.sh
│   │   └── shell/env.sh
│   ├── python/               # Python (pyenv)
│   │   ├── install.sh
│   │   └── shell/env.sh
│   ├── docker/               # Docker + Compose
│   │   ├── install.sh
│   │   └── shell/env.sh
│   └── rust/                 # Rust (rustup)
│       ├── install.sh
│       └── shell/env.sh
│
├── distros/                   # 发行版特定配置
│   ├── arch/
│   │   ├── packages.txt      # 软件包列表
│   │   ├── install.sh        # 安装脚本
│   │   └── shell/
│   │       └── arch.sh       # Arch 特定配置
│   ├── ubuntu/
│   │   ├── packages.txt
│   │   ├── install.sh
│   │   └── shell/
│   │       └── ubuntu.sh
│   ├── debian/
│   ├── fedora/
│   └── manjaro/
│
├── macos/                     # macOS 配置
│   ├── Brewfile              # Homebrew 包列表
│   └── shell/
│       └── macos.sh
│
├── wsl/                       # WSL 特定配置（叠加在发行版之上）
│   └── shell/
│       └── wsl.sh
│
├── scripts/                   # 辅助脚本
│   ├── detect_os.sh          # 系统检测
│   ├── setup_mirrors.sh      # 镜像源配置（国内优化）
│   ├── link.sh               # 符号链接管理
│   └── backup.sh             # 备份脚本
│
└── install.sh                 # 主安装脚本
```

## 快速开始

### 1. 克隆仓库

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
```

### 2. 运行安装脚本

**基础用法**（交互式，推荐）：

```bash
./install.sh
```

脚本会依次询问：
1. 是否配置国内镜像源（推荐，大幅提升下载速度）
2. 是否备份现有配置
3. 是否安装开发工具模块（可选）

**静默安装**（跳过所有交互，直接执行）：

```bash
# 跳过镜像源配置、跳过备份、跳过开发工具模块
./install.sh --skip-mirrors --skip-backup --skip-modules
```

**指定模块安装**：

```bash
# 自动安装 node 和 docker 模块（其余步骤跳过）
./install.sh --modules "node docker"
```

### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--skip-mirrors` | 跳过国内镜像源配置 | 交互式询问 |
| `--skip-backup` | 跳过现有配置备份 | 交互式询问 |
| `--skip-modules` | 跳过开发工具模块安装 | 交互式询问 |
| `--modules "name1 name2"` | 指定要安装的开发工具模块（空格分隔），同时自动跳过交互提示 | 交互式选择 |

**可用模块列表**：

| 模块 | 工具 | 说明 |
|------|------|------|
| `node` | fnm | Fast Node Manager，Rust 编写，比 nvm 快 |
| `java` | sdkman | 统一管理 JDK、Maven、Gradle |
| `python` | pyenv | 多版本 Python 管理 |
| `docker` | Docker + Compose | 容器引擎 + 镜像加速 |
| `rust` | rustup | Rust 工具链 |

**完整示例**：

```bash
# 一键安装（跳过所有交互，不安装任何模块）
./install.sh --skip-mirrors --skip-backup --skip-modules

# 安装所有模块（跳过镜像和备份）
./install.sh --skip-backup --modules "node java python docker rust"

# 只安装常用模块
./install.sh --modules "node docker python"
```

### 3. 使配置生效

```bash
source ~/.bashrc
```

或者重新登录系统。

## 配置加载顺序

配置文件按以下顺序加载（后加载的会覆盖先加载的）：

1. **通用配置** (`common/shell/`)
   - 所有系统共享的别名、函数、环境变量

2. **Linux 通用配置** (`linux/shell/`)
   - 所有 Linux 发行版共享的配置

3. **发行版特定配置** (`distros/{distro}/shell/`)
   - 特定发行版的配置和别名

4. **WSL 配置** (`wsl/shell/wsl.sh`)
   - 如果在 WSL 中运行，额外加载（叠加在发行版配置之上）

5. **macOS 配置** (`macos/shell/macos.sh`)
   - macOS 特定配置

6. **开发工具模块** (`modules/`)
   - 通过 `DOTFILES_MODULES` 环境变量控制加载
   - 示例: `export DOTFILES_MODULES="node java python docker"`

## 开发工具模块

通过 `modules/` 目录提供可插拔的开发工具安装和配置。

### 可用模块

> **完整模块列表见下方 [参数说明](#参数说明)**

### 使用模块

**安装时选择**：运行 `./install.sh` 后按提示选择模块。

**手动安装**：
```bash
# 安装单个模块
bash modules/node/install.sh
bash modules/java/install.sh

# 安装所有模块
for mod in modules/*/; do
    [ -d "$mod" ] || continue
    [[ "$(basename "$mod")" == _example ]] && continue
    bash "$mod/install.sh"
done
```

**环境变量加载**：模块的环境变量由 `.bashrc` 自动加载。

### 创建自定义模块

参考 `modules/_example/` 目录：
```
modules/mytool/
├── install.sh      # 安装逻辑
└── shell/
    └── env.sh      # 环境变量
```

## zsh 配置

项目使用 **Zinit** 作为 zsh 插件管理器。

### 安装

运行 `./install.sh` 后会链接 `~/.zshrc`。首次启动 zsh 时，`common/.zshrc` 会自动安装 Zinit。

### 插件

插件在 `common/.zshrc` 中通过 `zinit light` 管理，当前包含：
- `romkatv/powerlevel10k` - 主题
- `zdharma-continuum/fast-syntax-highlighting` - 语法高亮
- `zsh-users/zsh-autosuggestions` - 命令建议
- `joshskidmore/zsh-fzf-tab-completion` - Tab 补全增强

### 主题

默认主题：`powerlevel10k`（在 `common/.zshrc` 中配置）。

## 字体配置

### Nerd Font

终端图标需要 Nerd Font 支持。推荐使用 **JetBrains Mono Nerd Font**。

```bash
# 检测字体
bash common/font/nerd-font.sh check

# 安装字体
bash common/font/nerd-font.sh install
```

### 中文 CJK 支持

推荐安装 `Noto Sans CJK SC` 作为中文回退字体。

### 终端配置

各终端的字体配置片段位于 `linux/font/` 目录：
- `foot.conf` - foot (Wayland)
- `kitty.conf` - Kitty
- `alacritty.toml` - Alacritty
- `wezterm.lua` - WezTerm

## 使用示例

### 添加新的别名

**通用别名**（所有系统）：
编辑 `common/shell/aliases.sh`

**Linux 特定别名**：
编辑 `linux/shell/aliases.sh`

**Arch Linux 特定别名**：
编辑 `distros/arch/shell/arch.sh`

### 添加软件包

编辑对应发行版的 `packages.txt` 文件：

```bash
# 例如：Arch Linux
vim distros/arch/packages.txt
```

然后运行：

```bash
./distros/arch/install.sh
```

### 添加新的发行版支持

1. 创建发行版目录：
```bash
mkdir -p distros/newdistro/{shell,config}
```

2. 创建配置文件：
```bash
touch distros/newdistro/shell/newdistro.sh
touch distros/newdistro/packages.txt
touch distros/newdistro/install.sh
```

3. 编辑配置文件，参考现有发行版的格式

## 常用命令

安装后，你可以使用以下别名：

### 通用别名
- `..` - 返回上级目录
- `ll` - 详细列表
- `gs` - git status
- `gc` - git commit
- `reload` - 重新加载 .bashrc

### 系统特定别名

**Arch Linux:**
- `update` - 更新系统 (pacman -Syu)
- `install` - 安装软件包
- `remove` - 删除软件包
- `cleanup` - 清理系统

**Ubuntu/Debian:**
- `update` - 更新系统 (apt update && apt upgrade)
- `install` - 安装软件包
- `cleanup` - 清理系统

**macOS:**
- `update` - 更新 Homebrew 包
- `install` - 安装 Homebrew 包

## 手动操作

### 单独配置镜像源

如果只想配置镜像源而不安装其他内容：

```bash
./scripts/setup_mirrors.sh
```

该脚本会自动配置：
- 系统包管理器镜像源（pacman/apt/dnf/yum）
- pip 镜像源（阿里云）
- npm 镜像源（npmmirror）
- Docker 镜像加速（docker.1ms.run，可自定义配置）

### Docker 镜像加速使用

配置完成后，可以使用以下命令：

```bash
# 快速拉取镜像（推荐）
dp nginx:alpine
dp bitnami/nginx

# 拉取并自动重命名为原始镜像名
dpl nginx:alpine

# 查看当前镜像源配置
docker-mirror

# 修改镜像源配置
docker-mirror-edit
```

镜像源配置文件位于 `~/.docker/mirror.conf`，可以随时修改。

### 仅备份现有配置

```bash
./scripts/backup.sh
```

### 仅创建符号链接

```bash
./scripts/link.sh
```

### 检测操作系统

```bash
./scripts/detect_os.sh
```

## 自定义

### 修改 Dotfiles 目录位置

默认位置是 `~/.dotfiles`。如果你想使用其他位置：

1. 克隆到你想要的位置
2. 设置环境变量：
```bash
export DOTFILES_DIR="/path/to/your/dotfiles"
```

### 添加私有配置

创建 `~/.bashrc.local` 或 `~/.profile.local` 文件，添加你不想提交到 Git 的私有配置（如 API 密钥、公司特定配置等）。

在 `.bashrc` 末尾添加：
```bash
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
```

## 故障排除

### 配置没有生效

1. 确保运行了 `source ~/.bashrc`
2. 检查符号链接是否正确创建：
```bash
ls -la ~/.bashrc
```

### 找不到命令

某些别名可能依赖特定的软件包。确保已安装：
```bash
# Arch
./distros/arch/install.sh

# Ubuntu
./distros/ubuntu/install.sh
```

### 恢复备份

如果需要恢复之前的配置：
```bash
# 备份文件位于 ~/.dotfiles_backup_YYYYMMDD_HHMMSS/
cp -r ~/.dotfiles_backup_*/* ~/
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 测试

使用 Docker 快速测试 dotfiles 在不同发行版上的安装。

详细文档请查看 [TESTING.md](./TESTING.md)，常用命令：

```bash
# 测试单个发行版
./test/test.sh arch

# 测试所有发行版
./test/test.sh -a

# 交互式调试
./test/test.sh -i ubuntu

# 跳过测试（验证安装脚本的跳过逻辑）
./test/test.sh -s arch

# 清理测试环境
./test/test.sh -c
```

## 相关资源

- [Arch Wiki - Dotfiles](https://wiki.archlinux.org/title/Dotfiles)
- [GitHub Dotfiles](https://dotfiles.github.io/)
- [测试文档](./TESTING.md)
- [Docker 镜像加速指南](./docs/DOCKER_MIRRORS.md)
