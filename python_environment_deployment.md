# Python environment deployment
### Python 环境部署方案

1. 生成 requirements.txt 文件
```
pip freeze > requirements.txt
```
2. 下载 requirements.txt 文件中的依赖库
```
pip download -r requirements.txt -d ./ --platform=linux --python-version=3.6.5 --no-deps
说明：
    -r               : 指定 requirements.txt 文件
    -d               : 指定 Python 依赖库下载存放的位置
    --platform       : 指定下载哪个平台的 Python 依赖库
    --python-version : 指定下载哪个 Python 版本的依赖
```
3. 将 2 步骤下载的依赖库及 requirements.txt 文件打包上传到需要部署的环境
4. 安装 2 步骤中下载的依赖库
```
pip install --no-index -f ./ -r requirements.txt
说明：
    --no-index  : Ignore package index
    -f          : 已下载依赖库存放位置
    -r          : 指定 requirements.txt 文件
```
