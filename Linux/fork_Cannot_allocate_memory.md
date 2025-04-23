
#### 原因
进程数超限导致
1. 执行以下命令查看总进程数:
```bash
ps -efL | wc -l
```
2. 执行以下命令查看系统设置最大总进程数:
```bash
sysctl kernel.pid_max
```

#### 处理方案
- 临时方案:
```bash
sysctl -w kernel.pid_max=65535
```
- 永久生效
```bash
echo "kernel.pid_max = 65535" >> /etc/sysctl.conf
sysctl -p
```

>[!Note] pid_max 最大值 2<sup>22</sup> = 4194304 

#### 其他
- 查看lwp(轻量级进程，即线程)最多的进程
```bash
ps -eo nlwp,pcpu,user,pid,ppid,args --sort -nlwp | head -n 20

-nlwp 为 按nlwp倒序排序
```
