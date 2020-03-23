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

```
创建用户
db.createUser({user:'root',pwd:'root',roles:[{'role': 'root', db: 'admin'}]})
db.createUser({user:'admin',pwd:'admin',roles:[{'role': 'userAdminAnyDatabase', db: 'admin'}]})
db.createUser({user:'ztej',pwd:'ztej',roles:[{'role': 'readWrite', db: 'ztej'}]})
```

```json
数据表(collection)导入\导出
1. 导出
mongoexport --host=127.0.0.1 --port=27017 --db=test --username=test --password=test --collection=test --type=json -o test.json
2. 导入
mongoimport --host=127.0.0.1 --port=27017 --db=test --username=test --password=test --collection=test2 --file=./test.json --type=json
```

