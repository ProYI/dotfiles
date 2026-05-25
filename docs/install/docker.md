# Docker

Docker 不由 `install.sh` 自动安装，因为它会影响系统服务、用户组和镜像拉取策略。

## Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

重新登录后验证：

```bash
docker version
docker compose version
```

## Arch / Manjaro

```bash
sudo pacman -S --needed docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

## Fedora

```bash
sudo dnf install -y moby-engine docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

## 镜像加速建议

不要在 dotfiles 主安装脚本里默认改 Docker daemon。Docker 镜像代理和 `registry-mirrors` 可用性变化很快，建议按当前网络环境单独配置。

如果公司或个人网络已有代理，优先使用 Docker 官方支持的 proxy 配置或临时指定完整镜像地址。
