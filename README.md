# 配置说明
### 配置脚本到所在目录至环境变量path中
### 配置idea主目录至环境变量中(2选1)
1, 新建一项环境变量 IDEA_HOME_PATH, 对应的值为idea主目录文件夹
2, 或者将idea主目录bin文件夹路径配置至环境变量path中

# 使用说明
### 解压并打开
通过[Spring Initializr](https://start.spring.io/)https://start.spring.io/初始化下载项目后, 在.zip文同级目录下, 使用`uao ${your_download_zip}`运行命令
### 跳过替换wrapper镜像
在运行命令中加入`skipReplaceWrapper`参数, 使用`uao ${your_download_zip} skipReplaceWrapper`运行命令
