# Install Redis on Linux(CentOS 7)

##### 1、下载 Redis 包：  
&emsp;&emsp;在 https://redis.io/ 网页里下载   
##### 2、解压 Redis 源文件：  
```
tar -zxvf redis-5.0.5.tar.gz
```
##### 3、进入解压目录 编译、安装  
###### 编译：  
```
make
```
###### 安装：  
&emsp;&emsp;将redis.conf 及 src 目录下的 redis-server、redis-cli 三个文件复制到 /opt/redis-5.0.5/bin（随意） 目录下即可  
##### 4、配置 redis.conf 文件：
```
1.查找 port ，将端口改为 6389 （可选）
2.查找 daemonize ，将 daemonize no 改为 daemonize yes
3.查找 bind 127.0.0.1 ，将 bind 127.0.0.1 改为 bind 0.0.0.0
4.查找 requirepass ，在此行下面新建一行，内容为：requirepass 密码
```
##### 5、配置 PATH 环境变量
##### 6、启动：
```
redis-server /opt/redis-5.0.5/bin/redis.conf
```
##### 7、命令记录
###### 1 批量删除key
```shell
# 删除 db15 中 xxx 开头的key
./redis-cli -a {password} -n 15 keys "xxx*" | xargs ./redis-cli -a {password} -n 15 del
```
###### 2 监控模式
```shell
./redis-cli -a {password} monitor
```

##### 8、redis.service
```
[Unit]
Description=Redis
After=network.target

[Service]
Type=forking
ExecStart=/PATH_TO_SOFT/redis/redis-server /PATH_TO_SOFT/redis/redis.conf
ExecReload=/PATH_TO_SOFT/redis/redis-server /PATH_TO_SOFT/redis/redis.conf -s reload
ExecStop=/PATH_TO_SOFT/redis/redis-server /PATH_TO_SOFT/redis/redis.conf -s stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
> PATH_TO_SOFT 修改为`redis`所在对应目录
