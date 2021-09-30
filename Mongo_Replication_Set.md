# MongoDB 副本集搭建

> 本次演示使用 “一主一副一选举” 模式

## 1 设置主机名和IP的映射

将下列内容写入 `/etc/hosts` 文件

```txt
192.168.0.11 mongo.set.primary
192.168.0.12 mongo.set.second
192.168.0.13 mongo.set.arbiter
```

## 2 安装 MongoDB

本次实例为将下载好的 [mongodb](https://www.mongodb.com/download-center/community) 的`tgz`压缩包解压并放到 `/opt` 目录下， 并修改`mongodb`的目录名称为 `mongodb`,即`mongo`的安装目录为`/opt/mongodb/`，此目录修改需要替换配置文件中的路径

在`mongo`的安装目录创建数据存放目录及日志记录目录

```bash
mkdir -p data/db
mkdir log
cd log && touch mongodb.log
```

## 3 修改配置文件

将下列内容写入 `mongodb.conf `文件, `mongodb.conf `在`mongo`的安装目录`/opt/mongodb/`下的bin目录下

```yaml
# 系统日志
systemLog:
  destination: file
  path: "/opt/mongodb/log/mongodb.log"
  logAppend: true

# 数据存放路径
storage:
  dbPath: "/opt/mongodb/data/db"
  journal:
    enabled: true

# 后台进程
processManagement:
  fork: true

# IP 及 端口
net:
  bindIp: 0.0.0.0
  port: 27017

#用户认证
security:	# 第一次初始副本集时注释 security 配置
  authorization: enabled
  keyFile: /opt/mongodb/mongodb-keyfile	# keyFile

setParameter:
  enableLocalhostAuthBypass: false

replication:
   replSetName: set0	# 副本集别名，名称变更需要修改初始化中的副本集名称
```

## 4 初始化副本集

初始副本集时注释 `security` 配置,启动所有的`mongo`数据库

```
/opt/mongodb/bin/mongod -f /opt/mongodb/bin/mongodb.conf
```

登录主节点的`mongo`，运行一下命令

```bash
use admin
cfg={ _id:"set0", members:[ {_id:0,host:'mongo.set.primary:27017', priority: 10}, {_id:1,host:'mongo.set.second:27017', priority: 5}, {_id:2,host:'mongo.set.arbiter:27017',arbiterOnly:true, priority: 1}] };
rs.initiate(cfg)

priority: 表示权重，默认权重都是1
```

初始化后运行

```
rs.status()
```

查看各节点的健康情况， 没有异常则进行下一步

运行一下命令创建用户(root或其他高权限用户)

```
db.createUser({user:'root',pwd:'root',roles:[{'role': 'root', db: 'admin'}]})
```

然后依次从 选举节点>副节点>主节点 登录`mongo`，运行以下命令关闭服务

```bash
use admin
db.shutdownServer()
```

## 5 生产keyFile

在mongo安装目录即`/opt/mongodb/`下执行

```bash
openssl rand -base64 745 > mongodb-keyfile
mongodb-keyfile 为 keyFile 名称， 若改动需要同时修改配置文件中的路径名称
```

> 修改`keyFile`的权限为 600

```
chmod 600 mongodb-keyfile
```

> 同时生成的这个 keyFile 需要上传到另外的节点上

## 6 正式启动副本集

依次从 主节点>副节点>选举节 点启动`mongo`服务，然后登录主节点的admin库下运行

```
rs.status()
```

查看各节点的健康情况
