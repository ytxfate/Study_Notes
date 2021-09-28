# CentOS7 Operations
## CentOS7 系统维护

1. Change hostname  

```
hostnamectl set-hostname XXX    # 使用这个命令会立即生效且重启也生效
```

2. Add DNS

```
1. 显示当前网络连接
nmcli connection show
输出：
    NAME UUID                                 TYPE           DEVICE
    eno1 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03 802-3-ethernet eno1

2. 设置 DNS
nmcli con mod eno1 ipv4.dns "114.114.114.114"

3. 使dns配置生效
nmcli con up eno1
```

3. 同步时间服务器

```
1. 安装 ntp
yum install ntp

2. 同步时服务器
ntpdate cn.ntp.org.cn
```

4. 修改时区
```
ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
```
