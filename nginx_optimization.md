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

