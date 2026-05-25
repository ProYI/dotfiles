# Rust

Rust 推荐使用 rustup 安装。主安装脚本不自动安装 Rust，因为工具链版本、profile 和镜像选择经常因项目而异。

## 官方安装

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

安装后重新打开 shell，或执行：

```bash
source ~/.cargo/env
```

`common/shell/runtime.sh` 会在检测到 `~/.cargo/env` 时自动加载 Rust 环境。

## 国内镜像

如果下载慢，可以临时使用镜像：

```bash
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh
```

Cargo registry 镜像建议按项目或用户偏好配置，不由 dotfiles 默认覆盖 `~/.cargo/config.toml`。
