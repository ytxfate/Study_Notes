# Install Docker on Centos7

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

