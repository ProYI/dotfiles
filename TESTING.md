# Docker 测试方案

使用 Docker 容器快速测试 dotfiles 在不同 Linux 发行版上的安装，无需虚拟机。

## 为什么使用 Docker 而不是虚拟机？

| 特性 | Docker | 虚拟机 |
|------|--------|--------|
| 启动速度 | ⚡ 秒级 | 🐌 分钟级 |
| 资源占用 | 💾 几百 MB | 💽 几个 GB |
| 重建速度 | 🔄 快速 | 🔄 缓慢 |
| 自动化 | ✅ 容易 | ⚠️ 复杂 |
| 并行测试 | ✅ 支持 | ⚠️ 受限 |

## 前置要求

### 安装 Docker

**Arch Linux:**
```bash
sudo pacman -S docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**Ubuntu/Debian:**
```bash
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**Fedora:**
```bash
sudo dnf install docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

安装后需要**重新登录**使用户组生效。

### 配置镜像加速（国内用户推荐）

测试脚本会自动读取 `~/.docker/mirror.conf` 配置文件来使用镜像加速：

```bash
# 创建配置文件
mkdir -p ~/.docker
cat > ~/.docker/mirror.conf << 'EOF'
DOCKER_MIRROR="docker.1ms.run"
EOF
```

配置后，测试脚本会自动使用镜像加速拉取基础镜像，无需手动修改 Dockerfile。

**其他可用镜像源：**
- `docker.1ms.run` （推荐）
- `dockerpull.com`
- `docker.rainbond.cc`
- `docker.fxxk.dedyn.io`

## 快速开始

### 测试单个发行版

```bash
# 测试 Arch Linux
./test/test.sh arch

# 测试 Ubuntu
./test/test.sh ubuntu

# 测试 Debian
./test/test.sh debian

# 测试 Fedora
./test/test.sh fedora
```

### 测试所有发行版

```bash
./test/test.sh -a
```

输出示例：
```
==> 测试 arch...
==> 检测操作系统...
操作系统: arch
==> 测试配置加载...
✓ 别名 ll 可用
✓ 别名 gs 可用
✓ 函数 extract 可用
==> 测试完成！
✓ arch 测试通过

==> 测试 ubuntu...
...
```

### 交互式调试模式

当自动测试失败时，使用交互式模式手动调试：

```bash
./test/test.sh -i arch
```

进入容器后：
```bash
# 查看 dotfiles
cd ~/.dotfiles-test
ls -la

# 运行安装脚本
./install.sh

# 测试配置
source ~/.bashrc

# 测试别名和函数
ll
gs
extract --help

# 查看加载的配置
echo $DOTFILES_DIR
type update
```

按 `Ctrl+D` 或输入 `exit` 退出容器。

### 重新构建镜像

修改 Dockerfile 后需要重新构建：

```bash
./test/test.sh -b arch
```

### 清理测试环境

删除所有测试容器和镜像：

```bash
./test/test.sh -c
```

## 测试内容

自动测试会验证以下内容：

1. ✅ **系统检测** - 是否正确识别发行版
2. ✅ **配置加载** - 配置文件是否正确加载
3. ✅ **别名可用** - 通用别名（ll, gs）是否可用
4. ✅ **函数可用** - 通用函数（extract）是否可用
5. ✅ **环境变量** - 环境变量是否正确设置

## 支持的发行版

| 发行版 | 版本 | Dockerfile |
|--------|------|------------|
| Arch Linux | latest | `test/dockerfiles/Dockerfile.arch` |
| Ubuntu | 22.04 | `test/dockerfiles/Dockerfile.ubuntu` |
| Debian | 12 | `test/dockerfiles/Dockerfile.debian` |
| Fedora | 39 | `test/dockerfiles/Dockerfile.fedora` |

## 推荐工作流

### 开发新功能

```bash
# 1. 修改配置文件
vim distros/arch/shell/arch.sh

# 2. 快速测试单个发行版
./test/test.sh arch

# 3. 如果失败，进入交互式调试
./test/test.sh -i arch

# 4. 修复后，测试所有发行版
./test/test.sh -a

# 5. 提交更改
git add .
git commit -m "Add new feature"
```

### 修复 Bug

```bash
# 1. 重现问题
./test/test.sh -i ubuntu

# 2. 在容器内调试
cd ~/.dotfiles-test
# 修改文件，测试修复

# 3. 退出容器，应用修复到源文件
vim distros/ubuntu/shell/ubuntu.sh

# 4. 重新测试
./test/test.sh ubuntu
```

### 添加新发行版支持

```bash
# 1. 创建 Dockerfile
vim test/dockerfiles/Dockerfile.newdistro

# 2. 创建配置文件
mkdir -p distros/newdistro/{shell,config}
vim distros/newdistro/shell/newdistro.sh

# 3. 在 test.sh 中添加到 DISTROS 数组
vim test/test.sh

# 4. 测试
./test/test.sh -b newdistro
```

## 高级用法

### 并行测试多个发行版

```bash
# 在后台并行运行
./test/test.sh arch &
./test/test.sh ubuntu &
./test/test.sh debian &
wait
```

### 持久化容器（用于长期调试）

```bash
# 启动容器并保持运行
docker run -it --name my-test \
  -v $(pwd):/home/testuser/.dotfiles:ro \
  dotfiles-test-arch \
  /bin/bash

# 在另一个终端连接到同一容器
docker exec -it my-test /bin/bash

# 完成后删除
docker rm -f my-test
```

### 挂载可写的 dotfiles（用于容器内修改）

```bash
docker run -it --rm \
  -v $(pwd):/home/testuser/.dotfiles \
  dotfiles-test-arch \
  /bin/bash
```

⚠️ 注意：这会让容器内的修改直接影响宿主机文件。

## 故障排除

### Docker 权限错误

```
permission denied while trying to connect to the Docker daemon socket
```

**解决方法：**
```bash
sudo usermod -aG docker $USER
# 重新登录或运行
newgrp docker
```

### 镜像构建失败

```
ERROR: failed to solve: process "/bin/sh -c ..." did not complete successfully
```

**解决方法：**
```bash
# 清理并重新构建
./test/test.sh -c
./test/test.sh -b arch

# 或手动构建查看详细错误
docker build -f test/dockerfiles/Dockerfile.arch -t dotfiles-test-arch .
```

### 容器无法启动

**检查 Docker 服务：**
```bash
sudo systemctl status docker
sudo systemctl start docker
```

### 测试失败但不知道原因

**使用交互式模式调试：**
```bash
./test/test.sh -i arch

# 在容器内逐步执行
cd ~/.dotfiles-test
bash -x scripts/detect_os.sh  # 显示详细执行过程
source ~/.bashrc
```

### 磁盘空间不足

**清理 Docker 资源：**
```bash
# 清理测试镜像
./test/test.sh -c

# 清理所有未使用的 Docker 资源
docker system prune -a
```

## CI/CD 集成

### GitHub Actions 示例

创建 `.github/workflows/test.yml`：

```yaml
name: Test Dotfiles

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        distro: [arch, ubuntu, debian, fedora]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Test ${{ matrix.distro }}
      run: ./test/test.sh ${{ matrix.distro }}
```

### GitLab CI 示例

创建 `.gitlab-ci.yml`：

```yaml
test:
  image: docker:latest
  services:
    - docker:dind
  script:
    - ./test/test.sh -a
```

## 性能对比

在一台普通笔记本上的测试时间：

| 方法 | 单个发行版 | 4 个发行版 |
|------|-----------|-----------|
| Docker | ~30 秒 | ~2 分钟 |
| 虚拟机 | ~5 分钟 | ~20 分钟 |

## 最佳实践

1. **频繁测试** - 每次修改后立即测试
2. **测试所有发行版** - 提交前运行 `./test/test.sh -a`
3. **使用交互式模式** - 调试复杂问题时
4. **定期清理** - 避免占用过多磁盘空间
5. **版本控制 Dockerfile** - 确保测试环境可重现

## 扩展阅读

- [Docker 官方文档](https://docs.docker.com/)
- [Dockerfile 最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [测试框架源码](./test/)

## 常见问题

**Q: 为什么不用 GitHub Codespaces 或 Gitpod？**

A: 可以用，但 Docker 更灵活，可以本地运行，不依赖网络。

**Q: 可以测试 macOS 吗？**

A: Docker 不支持 macOS 容器。macOS 需要使用虚拟机（如 VirtualBox + Vagrant）或真实硬件。

**Q: 测试会修改我的系统吗？**

A: 不会。所有测试都在隔离的容器中运行，不影响宿主机。

**Q: 可以在 Windows 上运行吗？**

A: 可以，需要安装 Docker Desktop for Windows 或使用 WSL2 + Docker。

## 贡献

欢迎添加更多发行版的测试支持！请提交 PR。
