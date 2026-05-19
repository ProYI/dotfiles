# Docker 镜像加速使用指南

由于国内 Docker 官方镜像源访问受限，传统的 `registry-mirrors` 方式已失效。本项目提供了基于镜像代理的解决方案。

## 快速开始

### 1. 配置镜像源

运行安装脚本时会自动配置，或单独运行：

```bash
./scripts/setup_mirrors.sh
```

### 2. 重新加载配置

```bash
source ~/.bashrc
```

## 使用方法

### 方法一：使用 dp 命令（推荐）

`dp` 是 docker pull 的加速版本：

```bash
# 拉取官方镜像
dp nginx:alpine
dp redis:latest
dp mysql:8.0

# 拉取第三方镜像
dp bitnami/nginx
dp grafana/grafana
```

### 方法二：使用 dpl 命令（自动重命名）

`dpl` 会拉取镜像后自动重命名为原始名称：

```bash
# 拉取并重命名
dpl nginx:alpine

# 之后可以直接使用原始名称
docker run nginx:alpine
```

### 方法三：手动指定完整路径

```bash
# 官方镜像（需要加 library/ 前缀）
docker pull docker.1ms.run/library/nginx:alpine

# 第三方镜像
docker pull docker.1ms.run/bitnami/nginx
```

## 管理镜像源

### 查看当前配置

```bash
docker-mirror
```

### 修改镜像源

```bash
docker-mirror-edit
```

或直接编辑配置文件：

```bash
vim ~/.docker/mirror.conf
```

### 配置文件格式

```bash
# Docker 镜像加速配置
DOCKER_MIRROR="docker.1ms.run"

# 其他可用镜像源（如果上面的失效，可以尝试）
# DOCKER_MIRROR="dockerpull.com"
# DOCKER_MIRROR="docker.rainbond.cc"
# DOCKER_MIRROR="docker.fxxk.dedyn.io"
```

修改后重新加载配置：

```bash
source ~/.bashrc
```

## 常见问题

### Q: 为什么不使用传统的 registry-mirrors？

A: 传统的 Docker Hub 镜像站（如中科大、网易、阿里云等）在 2024 年后陆续停止服务。目前可用的方案是使用镜像代理服务。

### Q: 镜像源失效了怎么办？

A: 运行 `docker-mirror-edit` 修改配置文件中的 `DOCKER_MIRROR` 变量，替换为其他可用的镜像源。

### Q: 可以同时使用多个镜像源吗？

A: 目前脚本只支持配置一个主镜像源。如果需要切换，修改配置文件即可。

### Q: 拉取的镜像名称太长怎么办？

A: 使用 `dpl` 命令，它会自动重命名为原始镜像名称。

### Q: 如何验证镜像源是否可用？

A: 运行测试命令：

```bash
dp hello-world
```

如果能成功拉取，说明镜像源可用。

## 备用镜像源列表

以下是一些可用的镜像源（截至 2026 年 5 月）：

- `docker.1ms.run` （推荐）
- `dockerpull.com`
- `docker.rainbond.cc`
- `docker.fxxk.dedyn.io`

**注意**: 镜像源可用性可能随时变化，请根据实际情况选择。

## 高级用法

### 在 Dockerfile 中使用

```dockerfile
# 使用镜像代理
FROM docker.1ms.run/library/node:18-alpine

# 或者使用构建参数
ARG DOCKER_MIRROR=docker.1ms.run
FROM ${DOCKER_MIRROR}/library/node:18-alpine
```

### 在 docker-compose.yml 中使用

```yaml
version: '3'
services:
  web:
    image: docker.1ms.run/library/nginx:alpine
  db:
    image: docker.1ms.run/library/postgres:15
```

### 批量拉取镜像

创建一个脚本：

```bash
#!/bin/bash
images=(
    "nginx:alpine"
    "redis:latest"
    "postgres:15"
)

for image in "${images[@]}"; do
    dpl "$image"
done
```

## 贡献

如果你发现了新的可用镜像源，欢迎提交 PR 更新本文档。

## 相关资源

- [Docker Hub](https://hub.docker.com/)
- [Docker 官方文档](https://docs.docker.com/)
