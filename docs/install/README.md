# 扩展软件安装总览

主安装脚本只负责镜像源、基础包和 dotfiles 链接。下面这些软件安装过程差异大、影响系统状态较多，因此只提供文档，不自动安装。

| 软件 | 文档 | 为什么不自动安装 |
|------|------|------------------|
| Docker | [docker.md](docker.md) | 涉及服务、用户组、镜像加速和权限 |
| Node / fnm | [node.md](node.md) | 涉及版本选择、npm registry、shell 初始化 |
| Python | [python.md](python.md) | 系统 Python、venv、pyenv 的取舍因项目而异 |
| Rust | [rust.md](rust.md) | rustup 下载链路和镜像选择差异大 |
| Java / SDKMAN | [java.md](java.md) | JDK 发行版、版本和默认值因项目而异 |
| 字体 | [fonts.md](fonts.md) | 终端、字体和 CJK 回退偏好不同 |
| eza | [eza.md](eza.md) | 部分发行版需要额外源或 cargo |

建议先执行：

```bash
./install.sh --packages base,extra
```

确认基础工具可用后，再按需安装扩展软件。
