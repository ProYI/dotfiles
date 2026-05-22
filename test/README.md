# 测试框架

使用 Docker 容器测试 dotfiles 在不同 Linux 发行版上的安装。

## 前置要求

- Docker 已安装并运行

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

### 重新构建镜像

```bash
# 重新构建并测试
./test/test.sh -b arch
```

### 交互式模式

进入容器手动测试：

```bash
./test/test.sh -i arch
```

在容器内：

```bash
# 已自动复制到可写目录
cd ~/.dotfiles-test

# 运行安装脚本
./install.sh

# 测试配置
source ~/.bashrc
```

### 清理

删除所有测试容器和镜像：

```bash
./test/test.sh -c
```

## 测试内容

自动测试会验证：

1. ✅ 系统检测是否正确
2. ✅ 配置文件是否正确加载
3. ✅ 别名是否可用
4. ✅ 函数是否可用
5. ✅ 环境变量是否设置

## 支持的发行版

- Arch Linux
- Ubuntu 22.04
- Debian 12
- Fedora 39

## 添加新的发行版测试

1. 创建 Dockerfile：

```bash
touch test/dockerfiles/Dockerfile.newdistro
```

2. 编辑 Dockerfile，参考现有的格式

3. 在 `test.sh` 中添加到 `DISTROS` 数组

## 故障排除

### Docker 权限问题

如果遇到权限错误：

```bash
sudo usermod -aG docker $USER
# 重新登录
```

### 镜像构建失败

清理并重新构建：

```bash
./test/test.sh -c
./test/test.sh -b arch
```

### 容器无法启动

检查 Docker 服务：

```bash
sudo systemctl status docker
```
