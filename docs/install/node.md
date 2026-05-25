# Node / fnm

推荐使用 fnm 管理 Node 版本。主安装脚本不会自动安装 fnm，因为 Node 版本和 npm registry 通常按项目决定。

## 安装 fnm

```bash
curl -fsSL https://fnm.vercel.app/install | bash
```

重新打开 shell，或加载运行时配置：

```bash
source ~/.bashrc
```

`common/shell/runtime.sh` 已包含 fnm 初始化逻辑，检测到 `fnm` 后会自动执行 `fnm env --use-on-cd`。

## 使用国内 Node dist 镜像

如果下载 Node 很慢，可以临时设置：

```bash
export FNM_NODE_DIST_MIRROR="https://npmmirror.com/mirrors/node"
fnm install --lts
fnm default lts-latest
```

也可以把该变量放到 `config/proxy.conf` 或你的私有 shell 配置中。

## npm registry

项目不默认修改 npm registry。需要时手动设置：

```bash
npm config set registry https://registry.npmmirror.com
```

恢复官方 registry：

```bash
npm config set registry https://registry.npmjs.org
```
