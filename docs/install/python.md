# Python

Python 安装方式取决于用途：系统脚本推荐用发行版 Python，项目开发推荐用 `venv`、`uv` 或 `pyenv`。

## 系统 Python

Ubuntu / Debian：

```bash
sudo apt install -y python3 python3-pip python3-venv
```

Arch / Manjaro：

```bash
sudo pacman -S --needed python python-pip
```

Fedora：

```bash
sudo dnf install -y python3 python3-pip
```

## 虚拟环境

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -U pip
```

## pip 镜像

项目不默认修改 pip 配置。需要时手动创建 `~/.pip/pip.conf`：

```ini
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
```

如果经常跨网络环境工作，建议只在项目内或临时命令中指定镜像。
