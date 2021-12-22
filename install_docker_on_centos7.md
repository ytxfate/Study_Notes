# Install Docker Engine on CentOS7

### root 用户执行以下操作
https://docs.docker.com/install/linux/docker-ce/centos/
> ##### 1.安装依赖
> ```
> yum install -y yum-utils \
>   device-mapper-persistent-data \
>   lvm2
> ```
> ##### 2.配置yum源
> ```
> yum-config-manager \
>     --add-repo \
>     https://download.docker.com/linux/centos/docker-ce.repo
> ```
> ##### 3.安装
> ```
> yum install docker-ce docker-ce-cli containerd.io
> ```
> ##### 4.启动docker服务
> ```
> systemctl start docker
> ```
> ##### 5.测试
> 
> ```
> docker run hello-world
> ```
> ##### 6.卸载
> ```
> yum remove docker-ce
> rm -rf /var/lib/docker
> ```


### 解决运行docker命令要用root用户或sudo命令的问题
> ###### 第一步：创建docker用户组
> ```
> sudo groupadd docker
> ```
> ###### 第二步：用户加入到用户组
> ```
> sudo usermod -aG docker 用户名
> ```
> ###### 第三步：检查是否有效
> ```
> cat /etc/group
> ```
> ###### 第四步：重启docker-daemon
> ```
> sudo systemctl restart docker
> ```
> ###### 第五步：给docker.sock添加权限
> ```
> sudo chmod a+rw /var/run/docker.sock
> ```

### 后台运行 docker  
> ```
> docker run -itd --name centos7 centos
> ```

### 进入正在运行的 docker 容器
> ```
> docker exec -it centos7 /bin/bash
> ```

## docker 根目录迁移(<font color="red">不推荐方案</font>)

1. 找到 `Docker` 根目录

   ```bash
   docker info | grep "Docker Root Dir"
   输出:
    Docker Root Dir: /var/lib/docker
   ```

2. 停掉`Docker`服务

   ```bash
   systemctl stop docker
   ```

3. 迁移`Docker`根目录

   ```
   rsync -avzP /var/lib/docker /opt/docker_dir
   NOTE:
   	/opt/docker_dir 目录需提前建好
   rsync 参数解释：
       -a，归档模式，表示递归传输并保持文件属性。
       -v，显示rsync过程中详细信息。可以使用"-vvvv"获取更详细信息。
       -P，显示文件传输的进度信息。(实际上"-P"="--partial --progress"，其中的"--progress"才是显示进度信息的)。
       -z,   传输时进行压缩提高效率。
   ```

4. 将原来的`Docker`根目录移走

   ```bash
   cd /var/lib && mv docker docker.bak
   ```

5. 添加软连接

   ```bash
   ln -s /opt/docker_dir/docker /var/lib/docker
   ```

6. 重启`Docker`服务

   ```bash
   systemctl start docker
   ```

## docker 根目录迁移(<font color="red">推荐方案 18.06.1 测试成功</font>)

​	1 ~ 3 步骤与上面相同

4. 修改 `docker.service`文件

   ```bash
   文本内容：
   ExecStart=/usr/bin/dockerd
   修改成如下内容：
   ExecStart=/usr/bin/dockerd --graph /opt/docker_dir/docker
   ```

5. reload配置文件, 重启docker服务

   ```bash
   systemctl daemon-reload
   systemctl start docker.service
   ```

6. `docker info`查看是否修改成功

7. 重启之前容器


# Install Docker Engine from binaries

1. 下载 [docker](https://download.docker.com/linux/static/stable/) 二进制包

   ```bash
   tar -xzvf /path/to/<FILE>.tar.gz
   sudo cp docker/* /usr/bin/
   # 启动 不建议使用此方法，推荐 systemd 管理
   sudo dockerd &
   ```

2. systemd 管理

   1. 将 `docker.service` 及 `docker.socket` 复制到 `/etc/systemd/system` 目录下

   2. 执行一下命令

      ```
      systemctl daemon-reload
      systemctl restart docker.service
      systemctl enable docker.service (设置开机启动)
      ```

3. 配置 `daemon.json` 

# docker启用buildx插件，构建跨平台镜像
1. 更新docker版本到大于或等于19.03

2. 开启新特性（二选一，推荐第二种方式）

   1. 设置环境变量

      ```shell
      export DOCKER_CLI_EXPERIMENTAL=enabled
      ```

   2. 修改`～/.docker/config.json`,添加配置

      ```json
      "experimental": "enabled"
      ```

3. 启用binfmt_misc

   ```bash
   docker run --rm --privileged docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d
   ```

4. 验证是 binfmt_misc 否开启

   ```bash
   ls -al /proc/sys/fs/binfmt_misc/
   cat /proc/sys/fs/binfmt_misc/qemu-aarch64
   ```

5. 新建构建器

   ```bash
   docker buildx create --use --name mybuilder
   # 国内
   docker buildx create --use --name mybuilder --driver docker-container --driver-opt image=dockerpracticesig/buildkit:master
   ```

6. 启动构建器

   ```bash
   docker buildx inspect mybuilder --bootstrap
   ```

7. 查看构建器及其所支持的cpu架构

   ```bash
   docker buildx ls
   ```

8. 创建Dockerfile

9. 构建跨平台镜像

   ```bash
   docker buildx build --platform=linux/arm64 -f Dockerfile -t 'xxx-arm:v1.0' -o type=docker .
   ```


