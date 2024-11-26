# 脚本简介

本脚本旨在简化从 [Spring Initializr](https://start.spring.io/) 下载的 Spring 项目的初始化过程，通过以下功能提升开发效率：
- 自动解压 `generate` 后下载的 `.zip` 文件。
- 使用 IntelliJ IDEA 打开解压后的项目。
- 默认将 Maven 和 Gradle 的 Wrapper 镜像源替换为阿里巴巴开源镜像，以解决国内用户无法流畅访问默认镜像的问题。

---
# 配置说明

在 Windows 系统下运行此脚本前，请完成以下配置：

### 将脚本所在目录添加到Windows环境变量 `PATH`中

### 配置 IDEA 主目录到环境变量（以下两种方式二选一）

- 新建环境变量 `IDEA_HOME_PATH`，将 IDEA 主目录路径设置为该变量的值。
- 将 IDEA 主目录下的 `bin` 文件夹路径直接添加到Windows环境变量 `PATH` 中。

# 使用说明

### 解压并运行

通过 [Spring Initializr](https://start.spring.io/) 下载初始化项目后，在 `${Artifact}.zip` 文件的同级目录下，运行以下命令：

```shell
uao ${Artifact}.zip
```

### 跳过替换 Wrapper 镜像

> 默认行为：解压完成后，脚本会将 Maven 和 Gradle 的 Wrapper
> 源替换为 [阿里巴巴开源镜像](https://developer.aliyun.com/mirror/)

如需跳过该操作，可在运行命令时添加 `skipReplaceWrapper` 参数：

```shell
uao ${Artifact}.zip skipReplaceWrapper
```