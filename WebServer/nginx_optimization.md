# Nginx 性能优化

1. 网络优化
    `/etc/sysctl.conf` 文件 (sysctl -p 生效)
    ```
    net.core.somaxconn = 20480
    net.ipv4.tcp_tw_reuse = 1
    net.ipv4.tcp_tw_recycle = 1
    net.ipv4.ip_nonlocal_bind = 1
    ```

2. 系统优化
    `/etc/security/limits.conf` 文件 (注销登录生效) (<font style="color:red">CentOS7.4测试通过</font>)
    
    ```
    * soft nofile 65535 
    * hard nofile 65535
    ```
    
3. Nginx 配置优化
    ```
    worker_processes  8;	# cpu核数 * 2
    worker_rlimit_nofile 65535;		# ulimit -n 结果值
    events {
        use epoll;
        worker_connections 65535;	# 同 worker_rlimit_nofile
    }
    ```

4. 日志分割
    ```
    修改文件名称
    mv access.log access.log.1
    mv error.log error.log.1
    
    nginx -s reopen
    ```

    logrotate 日志分割
    ```
    /NGINX_ROOT_PATH/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 640 voyager voyager
    dateext
    minsize 1M
    sharedscripts
    postrotate
    [ -f /NGINX_ROOT_PATH/logs/nginx.pid ] && kill -USR1 `cat /NGINX_ROOT_PATH/logs/nginx.pid`
    endscript
    }
    ```

    > daily：表示每天进行日志切割；weekly 表示每周  
    > missingok：如果日志文件丢失，不会报错。  
    > rotate 7：保留7天的日志，超出的旧日志将被删除。  
    > compress：使用 gzip 压缩旧日志。  
    > delaycompress：不立即压缩当前日志，等待下一次轮转。  
    > notifempty：如果日志文件为空，则不进行轮转。  
    > create 644 nginx root：创建新的日志文件，设置权限和所有者。  
    > dateext ：这个参数很重要！就是切割后的日志文件以当前日期为格式结尾，如xxx.log-20131216这样,如果注释掉,切割出来是按数字递增,即前面说的 xxx.log-1这种格式  
    > sharedscripts：表示 postrotate 脚本对所有匹配的日志文件只执行一次。  
    > postrotate：执行的脚本，这里用于通知 Nginx 切换到新的日志文件  
    > minsize 1M ：文件大小超过 1M 后才会切割  
    > 
    > 测试 logrotate 配置：使用 logrotate -d /etc/logrotate.d/nginx 命令来测试配置文件，而不实际执行轮转。  
    > 手动执行 logrotate：如果需要立即执行日志切割，可以使用 logrotate -f /etc/logrotate.d/nginx。  
