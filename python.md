# python

1. 批量升级库

   ```bash
   pip install --upgrade $(pip list --outdated | grep wheel | awk '{print $1}')
   ```

2. 根据 requirements.txt 下载依赖库 (步骤2\3配合使用)

   ```bash
   pip download -r requirements.txt -d ./ --platform=linux --python-version=3.6.5 --no-deps
   
   说明：
       -r               : 指定 requirements.txt 文件
       -d               : 指定 Python 依赖库下载存放的位置
       --platform       : 指定下载哪个平台的 Python 依赖库
       --python-version : 指定下载哪个 Python 版本的依赖
   注意:
   	运行命令时可能出现一些意外的提示, 根据提示添加\修改数据项可解决问题
   ```

3. 根据 requirements.txt 安装步骤2中下载的依赖库(步骤2\3配合使用)

   ```bash
   pip install --no-index -f ./ -r requirements.txt
   说明：
       --no-index  : Ignore package index
       -f          : 已下载依赖库存放位置
       -r          : 指定 requirements.txt 文件
   ```

