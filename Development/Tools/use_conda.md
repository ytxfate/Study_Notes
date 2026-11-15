# Use Conda on Ubuntu

## 1 下载

[Miniconda(测试日期 2020-05-14)](https://docs.conda.io/en/latest/miniconda.html)

**其他下载地址**

[清华大学开源软件镜像站(测试日期 2020-05-14)](https://mirror.tuna.tsinghua.edu.cn/)

## 2 安装

```bash
bash Miniconda3-latest-Linux-x86_64.sh
```

安装过程中,`conda` 提示需要把路径加到`PATH`中时,为了避免环境变量被污染,最好选择 `No`

可以把 `conda`,`activate`,`deactivate`使用软链接的方式放到`/usr/local/bin/`

## 3 使用

### 3.1 创建虚拟环境

```bash
conda create -n XXX python=版本
```

### 3.2 激活虚拟环境

```bash
source activate XXX
```

### 3.3 退出虚拟环境

```bash
source deactivate
```

### 3.4 删除虚拟环境

```bash
conda env remove -n XXX
```

### 3.5 安装依赖

```bash
conda install xxx 或 pip install xxx
```

