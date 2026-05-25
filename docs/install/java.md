# Java / SDKMAN

Java 生态建议用 SDKMAN 管理 JDK、Maven、Gradle 等工具。主安装脚本不自动安装 SDKMAN，因为 JDK 发行版和默认版本通常按项目决定。

## 安装 SDKMAN

```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

`common/shell/runtime.sh` 会在检测到 SDKMAN 初始化脚本时自动加载。

## 安装 JDK

查看可用 JDK：

```bash
sdk list java
```

安装某个版本：

```bash
sdk install java <version>
sdk default java <version>
```

建议不要在通用 dotfiles 中固定 JDK 版本；项目需要的版本应写在项目文档或 `.sdkmanrc` 中。
