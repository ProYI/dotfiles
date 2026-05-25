# Dotfiles - 多系统配置管理

一个支持多个操作系统和 Linux 发行版的配置文件管理方案。

## 发行版支持情况

| 发行版 | 状态 | 说明 |
|--------|------|------|
| Debian | ✅ 已测试 | 主要开发和测试平台 |
| Ubuntu | ⚠️ 未测试 | 结构已就绪，待测试 |
| Arch Linux | ⚠️ 未测试 | 结构已就绪，待测试 |
| Fedora | ⚠️ 未测试 | 结构已就绪，待测试 |
| Manjaro | ⚠️ 未测试 | 结构已就绪，待测试 |
| macOS | ⚠️ 未测试 | 结构已就绪，待测试 |

**说明**：
- ✅ 已测试：经过完整测试，可以正常使用
- ⚠️ 未测试：项目结构已创建，但尚未在该平台上测试

## 特性

- ✅ **多系统支持**: Linux、macOS
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
│   │   └── loader.sh         # 配置加载器（分层加载逻辑）
│   ├── .bashrc               # Bash 配置
│   ├── .zshrc                # Zsh 配置 (Zinit)
│   ├── .profile              # Shell profile
│   ├── .vimrc                # Vim 配置
│   ├── .gitconfig            # Git 配置
│   ├── .tmux.conf            # Tmux 配置
│   └── .ssh/                 # SSH 配置模板
│       └── config            # SSH 模板（复制到 ~/.ssh/config）
│
├── config/                    # 全局配置文件
│   ├── dotfiles.conf         # Dotfiles 目录配置
│   ├── packages.conf         # 逻辑包名列表（跨发行版）
│   └── proxy.conf            # 代理和镜像源配置（本地设置，不提交）
│
├── linux/                     # Linux 通用配置
│   ├── shell/
│   │   ├── aliases.sh        # Linux 通用别名
│   │   └── exports.sh        # Linux 通用环境变量
│   └── font/                  # 终端字体配置片段
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
│   ├── rust/                 # Rust (rustup)
│   │   ├── install.sh
│   │   └── shell/env.sh
│   ├── eza/                  # eza (现代 ls 替代品)
│   │   └── install.sh
│   └── nerd-font/            # Nerd Font 安装
│       └── install.sh
│
├── distros/                   # 发行版特定配置
│   ├── arch/
│   │   ├── config/           # 发行版特定配置文件
│   │   ├── packages-map.sh   # 逻辑包名到实际包名的映射
│   │   ├── install.sh        # 安装脚本
│   │   └── shell/
│   │       └── arch.sh       # Arch 特定配置
│   ├── ubuntu/
│   │   ├── config/
│   │   ├── packages-map.sh
│   │   ├── install.sh
│   │   └── shell/
│   │       └── ubuntu.sh
│   ├── debian/
│   ├── fedora/
│   └── manjaro/
│
├── macos/                     # macOS 配置
│   └── shell/
│       └── macos.sh          # macOS 特定配置
│
├── scripts/                   # 辅助脚本
│   ├── lib/                  # 公共脚本库
│   │   ├── common.sh         # 通用工具函数
│   │   ├── log.sh            # 日志输出函数
│   │   ├── module.sh         # 模块安装公共函数
│   │   ├── package-manager.sh # 包管理器抽象层
│   │   ├── packages.sh       # 包安装和映射逻辑
│   │   └── proxy.sh          # 代理配置处理
│   ├── detect_os.sh          # 系统检测
│   ├── setup_mirrors.sh      # 镜像源配置（国内优化）
│   ├── link.sh               # 符号链接管理
│   ├── backup.sh             # 备份脚本
│   └── doctor.sh             # 环境诊断工具
│
├── test/                      # Docker 测试框架
│   ├── dockerfiles/          # 各发行版 Dockerfile
│   ├── test.sh               # 测试脚本
│   └── README.md             # 测试文档
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
| `eza` | eza | 现代化的 ls 替代品，支持图标和 Git 集成 |
| `nerd-font` | Nerd Font | 编程字体，支持图标和符号 |

**完整示例**：

```bash
# 一键安装（跳过所有交互，不安装任何模块）
./install.sh --skip-mirrors --skip-backup --skip-modules

# 安装所有模块（跳过镜像和备份）
./install.sh --skip-backup --modules "node java python docker rust eza nerd-font"

# 只安装常用模块
./install.sh --modules "node docker python eza nerd-font"
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

4. **macOS 配置** (`macos/shell/macos.sh`)
   - macOS 特定配置

5. **开发工具模块** (`modules/`)
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
bash modules/nerd-font/install.sh
bash modules/eza/install.sh

# 安装所有模块（跳过模板）
for mod in modules/*/; do
    [ -d "$mod" ] || continue
    mod_name="$(basename "$mod")"
    [[ "$mod_name" == _example ]] && continue
    bash "$mod/install.sh"
done
```

**环境变量加载**：模块的环境变量由 `.bashrc` 自动加载。

### 创建自定义模块

参考 `modules/_example/` 目录：
```
modules/mytool/
├── install.sh      # 安装逻辑
└── shell/          # 可选：如果需要环境变量配置
    └── env.sh      # 环境变量
```

**注意**：`shell/` 目录是可选的。如果模块只需要安装工具而不需要配置环境变量（如 `eza`、`nerd-font`），可以省略 `shell/` 目录。

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
# 使用模块安装
bash modules/nerd-font/install.sh
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

优先把新软件写成“逻辑包名”，放到 `config/packages.conf` 中：

```bash
vim config/packages.conf
```

例如添加 Firefox ESR：

```conf
# ==================== 浏览器 ====================
包:firefox
包:firefox-esr
包:chromium
```

各发行版实际包名不同的情况，在对应 `packages-map.sh` 中做映射：

```bash
# 例如 Ubuntu 没有 firefox-esr 时，退化安装普通 firefox
["firefox-esr"]="firefox"
```

处理规则：

- `config/packages.conf` 写逻辑包名，表达“要安装什么能力/软件”。
- `distros/<distro>/packages-map.sh` 写发行版实际包名映射。
- 如果某发行版实际包名和逻辑包名一致，不需要写映射。
- 如果一个逻辑包需要多个实际包，可以映射成空格分隔的列表，例如 `["build-tools"]="gcc make"`。
- 如果安装需要第三方源、下载 release、安装脚本或版本差异较大，不要放普通包列表，改成 `modules/<name>/install.sh` 模块。

推荐流程：

1. 先加到 `config/packages.conf`。
2. 如果确定各发行版同名，不动 `packages-map.sh`。
3. 如果某发行版包名不同，在对应 `packages-map.sh` 加映射。
4. 如果需要加源、下载二进制或处理复杂兼容逻辑，升级成模块。

### 添加新的发行版支持

1. 创建发行版目录：
```bash
mkdir -p distros/newdistro/{shell,config}
```

2. 创建配置文件：
```bash
touch distros/newdistro/shell/newdistro.sh
touch distros/newdistro/packages-map.sh
touch distros/newdistro/install.sh
```

3. 在 `install.sh` 的发行版分支中接入 `newdistro`

4. 编辑配置文件，参考现有发行版的格式

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

### 环境诊断

使用 `doctor.sh` 检查 dotfiles 配置是否正确加载：

```bash
# 检查所有配置
./scripts/doctor.sh

# 检查特定范围
./scripts/doctor.sh packages  # 检查已安装的包
./scripts/doctor.sh modules   # 检查已安装的模块
```

该脚本会验证：
- 系统检测是否正确
- 配置文件是否正确加载
- 别名和函数是否可用
- 环境变量是否设置
- 已安装的包和模块状态

## 自定义

### 修改 Dotfiles 目录位置

默认位置是 `~/.dotfiles`。如果你想使用其他位置：

**方式一：配置文件（推荐）**

编辑 `config/dotfiles.conf`，设置 `DOTFILES_DIR`：

```bash
# 修改 config/dotfiles.conf 中的 DOTFILES_DIR 变量
DOTFILES_DIR="/path/to/your/dotfiles"
```

**方式二：环境变量**

```bash
export DOTFILES_DIR="/path/to/your/dotfiles"
```

**方式三：克隆到任意位置**

```bash
git clone <your-repo-url> /path/to/your/dotfiles
cd /path/to/your/dotfiles
```

脚本会自动检测仓库所在目录作为 `DOTFILES_DIR`。

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
