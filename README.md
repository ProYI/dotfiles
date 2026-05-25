# Dotfiles - Linux 配置文件管理

通过符号链接管理 shell、编辑器、终端等配置文件，并提供轻量 bootstrap：检查/配置镜像源、安装基础软件包、链接配置文件。

本项目不追求一键安装所有开发环境。Docker、Node、Rust、Java、Python 版本管理器、字体等复杂扩展软件只提供文档，用户按需手动安装。

## 快速开始

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
source ~/.bashrc
```

常用参数：

```bash
# 只链接配置，不改镜像源，不安装基础包
./install.sh --skip-mirrors --skip-packages

# 安装基础包和增强包
./install.sh --packages base,extra

# 已确认需要配置镜像源和安装基础包时，减少交互
./install.sh --yes

# 强制重写镜像源（默认检测到已有国内源会跳过）
./install.sh --force-mirrors
```

## install.sh 做什么

1. 检测当前系统。
2. 检查并按需配置系统包管理器镜像源。
3. 备份已有 dotfiles 配置到 `~/.dotfiles_backup/<timestamp>`。
4. 删除旧 `~/.dotfiles`，复制当前项目内容到 `~/.dotfiles`。
5. 从 `~/.dotfiles` 链接 shell、git、vim、tmux、终端字体等配置。
6. 按需安装基础软件包。
7. 提示复杂扩展软件文档入口。

## 基础软件包

基础包清单在 `config/packages.conf`：

| 分类 | 说明 |
|------|------|
| `base` | 新机器默认建议安装，保证 dotfiles 基础体验可用 |
| `extra` | 增强工具，需要时手动选择 |

示例：

```bash
./install.sh --packages base
./install.sh --packages base,extra
./install.sh --skip-packages
```

当前基础包包括：`git`、`curl`、`wget`、`ca-certificates`、`zsh`、`vim`、`tmux`、`fzf`、`ripgrep`、`fd`、`bat`、`jq`、`unzip`、`zip`、`tree`。

## 镜像源策略

`scripts/setup_mirrors.sh` 只处理系统包管理器镜像源：

- Ubuntu/Debian：检测 apt 源是否已有国内镜像；没有时才写入阿里云源。
- Arch/Manjaro：检测 pacman mirrorlist 是否已有国内镜像；没有时才写入常用国内源。
- Fedora：暂不自动改写 repo，仅提示手动配置。

所有系统源文件写入前都会备份。默认不会修改 npm、pip、Docker daemon。

## 扩展软件安装

复杂软件请按需阅读文档后手动安装：

- [扩展软件总览](docs/install/README.md)
- [Docker](docs/install/docker.md)
- [Node / fnm](docs/install/node.md)
- [Python](docs/install/python.md)
- [Rust](docs/install/rust.md)
- [Java / SDKMAN](docs/install/java.md)
- [字体](docs/install/fonts.md)
- [eza](docs/install/eza.md)

## 备份策略

每次安装都会自动备份，不再询问。备份目录固定为 `~/.dotfiles_backup/<timestamp>`，并只保留最近 7 次备份，避免长期积累。

## 链接了哪些配置

安装脚本会先复制当前项目到 `~/.dotfiles`，下面的链接目标都指向 `~/.dotfiles`，因此移动或删除原项目目录不会影响已安装配置。

| 配置文件 | 链接到 |
|---------|--------|
| `common/.bashrc` | `~/.bashrc` |
| `common/.zshrc` | `~/.zshrc` |
| `common/.profile` | `~/.profile` |
| `common/.gitconfig` | `~/.gitconfig` |
| `common/.vimrc` | `~/.vimrc` |
| `common/.tmux.conf` | `~/.tmux.conf` |
| `common/.ssh/config` | `~/.ssh/config`（仅复制模板） |
| `linux/font/*.conf` | `~/.config/<terminal>/` |

## 配置加载顺序

`.bashrc` / `.zshrc` → `loader.sh` → 按顺序 source：

1. `common/shell/exports.sh` — 环境变量
2. `common/shell/aliases.sh` — 通用别名
3. `common/shell/functions.sh` — 通用函数
4. Linux: `linux/shell/exports.sh` + `aliases.sh`
5. macOS: `macos/shell/macos.sh`
6. `common/shell/runtime.sh`（需 `DOTFILES_LOAD_RUNTIME_EXTRAS=1`）— fnm/sdkman/cargo 等工具环境初始化

## 如何自定义

**添加配置文件**：放到 `common/` 或 `linux/`，然后在 `scripts/link.sh` 加链接逻辑。

**添加基础包**：编辑 `config/packages.conf`。如果发行版包名不同，在 `scripts/lib/package-manager.sh` 的 `dotfiles_resolve_package()` 中加映射。

**添加别名**：编辑 `common/shell/aliases.sh`（通用）或 `linux/shell/aliases.sh`（Linux）。

**添加运行时工具初始化**：编辑 `common/shell/runtime.sh`，加一个守卫块：

```bash
if command -v mytool &> /dev/null; then
    eval "$(mytool init)"
fi
```

**私有配置**：创建 `~/.bashrc.local` 或 `~/.zshrc.local`，不会被 git 管理。

## 目录结构

```text
dotfiles/
├── common/              # 所有系统通用配置
├── config/              # 软件包、代理等配置
├── docs/install/        # 复杂扩展软件安装文档
├── linux/               # Linux 配置
├── macos/               # macOS 配置
├── scripts/             # 安装、备份、链接、镜像脚本
│   └── lib/             # 工具函数
└── README.md
```

## 许可证

MIT License
