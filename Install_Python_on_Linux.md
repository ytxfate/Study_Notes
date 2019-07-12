# Install Python on Linux(CentOS 7)
```
0、安装 openssl-devel 工具包
（若要使用 pip 安装依赖，需要有 openssl 支持，但一般都只是缺少了 openssl-devel 工具包）
   yum install openssl-devel.x86_64  
1、下载 Python 包：  
   在 https://www.python.org/downloads/ 网页里下载 Python-x.x.x.tgz 源文件  
2、解压 Python 源文件：  
   tar -zxvf tar -zxvf Python-x.x.x.tgz  
3、进入解压目录 配置、编译、安装  
   配置：  
      ./configure --prefix=/opt/python3  
      （ prefix 选项表示安装到 /opt/python3 目录下）  
   编译：  
     make  
   安装：  
      make install
4、配置 PATH 环境变量
```