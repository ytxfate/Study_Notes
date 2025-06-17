1. 安装 rsync
```bash
# Ubuntu/Debian安装rsync
sudo apt update
sudo apt install -y rsync
# CentOS/RHEL安装rsync
sudo yum install -y rsync
# CentOS 8安装rsync daemon
sudo yum install -y rsync-daemon
```
2. 配置 `/etc/rsyncd.conf` 文件
```
# rsyncd.conf的配置项分全局参数和模块参数，全局参数只有少数几个，一般保持默认即可
# 模块以[模块名]开头，后续参数仅作用于该模块
# 卸载模块外的参数适用于所有模块
# rsyncd.conf文件的指令和值请参考 man rsyncd.conf

# 欢迎文件
motd file = /etc/rsyncd.d/rsyncd.motd

# 用户和组id
uid = root
gid = root

# 是否chroot，出于安全考虑建议为yes
use chroot = yes
# 是否记录传输记录
transfer logging = no
# 是否只读，值为true时客户端无法上传
read only = false
# 是否只写，值为true时客户端无法下载
write only = false
# 默认拒绝所有主机连接
hosts deny = *

# 用户名密码文件，每一行格式是：用户名:密码，例如
# user:pwd
# 该文件权限必须设置为600，除非strict mode设置为false
secrets file = /etc/rsyncd.d/rsyncd.secrets

# 定义名为backup的模块
[backup]
# 模块说明
comment = backup directory
# 模块路径，请求改成自己的
path = /data
# 允许的主机ip
hosts allow = xxx.xxx.xxx.xxx
# 允许的用户名
auth users = testrsync
# 是否允许列出该模块，建议为no
list = no
```
3. 配置欢迎文件 `/etc/rsyncd.d/rsyncd.motd` , 内容随意, `rsync` 同步的时候会显示在客户端
```
欢迎使用Rsync Daemon
```
4. 配置用户名密码文件 `/etc/rsyncd.d/rsyncd.secrets` , 并设置文件权限 `600`
```
username:password
```
5. 启动 `rsync` 服务
```bash
# CentOS/RHEL
systemctl enable rsyncd
systemctl start rsyncd

# Ubuntu/Debian的服务名为rsync
systemctl enable rsync
systemctl start rsync
```
6. 客户端配置 `passwd` 文件, 文件名称随意, 例如 `testrsync.passwd` , 将密码写入文件
7. 同步
```bash
# 本地同步到远程
rsync -az --bwlimit=10m --delete --password-file=./testrsync.passwd ./project testrsync@xxx.xxx.xxx.xxx::backup

# 远程同步到本地
rsync -az --bwlimit=10m --delete --password-file=./testrsync.passwd testrsync@xxx.xxx.xxx.xxx::backup ./project

# backup 为 /etc/rsyncd.conf 中定义的模块
# --bwlimit 为限流
# --delete 删除本地不存在,远程存在的目录
```
8. `crontab` 添加定时同步
```
0 1 * * * rsync -az --bwlimit=10m --delete --password-file=./testrsync.passwd ./project testrsync@xxx.xxx.xxx.xxx::backup
# 每天凌晨1点执行一次同步
```
9. `--include-from` 方式包含部分文件 <font color="#ffc000">(由于顺序匹配, `include` 类过滤最好在 `exclude` 类过滤之前)</font>
```bash
rsync -az --bwlimit=10m --delete --include-from=include-file.txt --password-file=./testrsync.passwd ./project testrsync@xxx.xxx.xxx.xxx::backup
```
`include-file.txt` 文件内容如下:
```
*/cc.txt
```
10. `--exclude-from` 方式排除部分文件
```
rsync -az --bwlimit=10m --delete --exclude-from=exclude-file.txt --password-file=./testrsync.passwd ./project testrsync@xxx.xxx.xxx.xxx::backup
```
`exclude-file.txt` 文件内容如下:
```
*.bak*
modules/*
*.tar
*.tar.gz
*.tgz
*.zip
```
