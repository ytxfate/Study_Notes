# Install Mongodb on Linux(CentOS 7)

##### 0、安装 libcurl、openssl 工具包：  
```
yum install libcurl openssl
```
##### 1、下载 Mongodb 包：  
&emsp;&emsp;在 https://www.mongodb.com/download-center/community 网页里点击 server ，根据系统选择不同版本进行下载  
##### 2、解压文件：  

```
tar -zxvf mongodb-linux-x86_64-rhel70-4.0.5.tgz
```

##### 3、将解压得到的目录移动到 /opt 并重命名为 mongodb-4.0.5（文件名随意）  
##### 4、配置 PATH 环境变量（此步可以最后设置）  
##### 5、配置 mongodb.conf 文件（示例如下）：  
```
# 系统日志
systemLog:
  destination: file
  path: "/opt/mongodb-4.0.5/log/mongodb.log"
  logAppend: true

# 数据存放路径
storage:
  dbPath: "/opt/mongodb-4.0.5/data/db"

# 后台进程
processManagement:
  fork: true
  # 指定 pid 文件, 方便 logrotate 分割日志
  pidFilePath: /opt/mongodb-4.0.5/mongod.pid

# IP 及 端口
net:
  bindIp: 0.0.0.0
  port: 27017

#用户认证
security:
  authorization: enabled

setParameter:
  enableLocalhostAuthBypass: true
```
##### 6、启动：  

```
mongod -f ./mongodb.conf
```

##### 7、创建用户

```
创建用户
db.createUser({user:'root',pwd:'root',roles:[{'role': 'root', db: 'admin'}]})
db.createUser({user:'admin',pwd:'admin',roles:[{'role': 'userAdminAnyDatabase', db: 'admin'}]})
db.createUser({user:'testuser',pwd:'testuser',roles:[{'role': 'readWrite', db: 'testdb'}]})
```

##### 8、导入/导出

```json
数据表(collection)导入\导出
1. 导出
mongoexport --host=127.0.0.1 --port=27017 --db=test --username=test --password=test --collection=test --type=json -o test.json
2. 导入
mongoimport --host=127.0.0.1 --port=27017 --db=test --username=test --password=test --collection=test2 --file=./test.json --type=json
```

##### 9、备份/恢复

```json
数据库(database)备份\恢复
1. 备份(会在当前目录下新建一个test库名称的目录)
1.1 全量备份
mongodump --host=127.0.0.1 --port 27017 --db=test -o ./ --gzip
1.2 单表备份
mongodump --host=127.0.0.1 --port 27017 --db=area --collection pop_info -o ./ --gzip

2. 恢复(drop会清空test2库后导入数据)
2.1 全量恢复
mongorestore --host=127.0.0.1 --port 27017 --db=test2 --gzip --dir test --drop
2.2 全量恢复( test库 恢复到 test2库 )
mongorestore --nsInclude='test.*' --nsFrom='test.*' --nsTo='test2.*' --dir . --drop --gzip
2.3 单表恢复( test库的t表 恢复到 test2库t表[t表名称可修改] nsFrom与nsTo需要相匹配)
mongorestore --nsInclude='test.t' --nsFrom='test.t' --nsTo='test2.t' --dir . --drop --gzip --username xxx --password xxx --authenticationDatabase test2
```

##### 10、日志分割

方法1:

```
use admin
db.runCommand({logRotate:1})
```

方法2:

```shell
mongo --host 127.0.0.1 --port 27017 --authenticationDatabase admin --username root --password root --eval "db.runCommand({\"logRotate\":1})" admin
```

方法3:

```shell
kill -SIGUSR1 {mongod PID}
```

##### 11 单表权限控制

```js
参考: https://www.mongodb.com/docs/v4.2/reference/method/db.createRole/
// 创建角色
db.createRole(
    {
        role: "testRead",
        privileges: [
            {resource: {db: "testdb",collection: "testcoll"}, actions: ["find"]},
            {resource: {db: "testdb",collection: "testcoll2"}, actions: ["insert", "remove", "update", "find"]},	// 增删改查
        ],
        roles: []	// 继承的权限(设置单表权限的时候不需要)
    }
)
// 修改角色权限范围
db.updateRole(
    "testRead",
    {
        privileges: [
            {resource: {db: "testdb",collection: "testcoll"}, actions: ["find"]},
            {resource: {db: "testdb",collection: "testcoll2"}, actions: ["insert"]},
        ]
    }
)
// 查询角色
db.getRole('testRead', {'showPrivileges': 1})

// 修改用户角色
db.updateUser(
	"testuser",
	{
		roles : [
			{ role: "testRead", db: "testdb" },
		],
	}
)
```

##### 12 修改密码

```js
db.changeUserPassword("testuser", passwordPrompt())
db.changeUserPassword("testuser", "123456")
```

##### 13 查看表占用空间

```js
// 查看当前库所有表的空间占用
db.getCollectionNames().forEach( function (item) { 
    stats=db.runCommand({collStats:item});
    sizeGB = stats.storageSize/1024/1024;
    prettyGB = Math.round(sizeGB)+ 'MB';
    print(item, prettyGB)
})

// 查看 collection_name 表的空间占用
db.collection_name.stats().storageSize/1024/1024

// compact 重写集合中的所有数据以及该集合上的所有索引并对其进行碎片整理
// 注: 副本集需要现在副节点执行, 主节点执行需要加 force:true 选项
//     该命令会阻止所有其他活动。从版本2.2开始，compact只阻止它正在压缩的数据库的活动。
db.runCommand({compact:'collection_name'})
```

##### 14 查看系统状态
```
mongostat -h 127.0.0.1 --port 27017 --authenticationDatabase=admin -u root -p root

mongotop -h 127.0.0.1 --port 27017 --authenticationDatabase=admin -u root -p root
```

##### 15 logrotate 日志分割
```
/opt/mongodb-4.0.5/log/*.log {     # 需要进行日志切割的日志文件的位置
    # 条件：大于这个条件时会进行切割
    size 200M
    daily                    # 执行周期：daily，weekly，monthly，yearly
    missingok
    # 保留多少个，超过这个数时，最久的日志文件将会被删除
    rotate 5
    copytruncate             # 把正在输出的日志拷贝一份出来，然后清空源文件
    dateext                  # 轮询的日志以日期结尾
    notifempty               # 忽略空文件
    missingok                # 如果文件不存在则忽略
    postrotate               # 脚本开始标志
        /bin/kill -SIGUSR1 `cat /opt/mongodb-4.0.5/mongod.pid 2>/dev/null` > /dev/null 2>&1
    endscript                # 脚本结束标志
    compress                 # 切割后压缩，也可以为nocompress
    delaycompress            # 切割时对上次的日志文件进行压缩
    # 使用指定模式创建日志文件
    create 640 mongodb mongodb
}
```

##### 16 mongodb.service
```
[Unit]
Description=mongodb
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
RuntimeDirectory=mongodb
RuntimeDirectoryMode=0751
PIDFile=/PATH_TO_SOFT/mongodb/mongodb.pid
ExecStart=/PATH_TO_SOFT/mongodb/bin/mongod -f /PATH_TO_SOFT/mongodb/bin/mongodb.conf
ExecStop=/PATH_TO_SOFT/mongodb/bin/mongod --shutdown -f /PATH_TO_SOFT/mongodb/bin/mongodb.conf
PrivateTmp=false

[Install]
WantedBy=multi-user.target
```
> PATH_TO_SOFT 修改为`mongodb`所在对应目录
