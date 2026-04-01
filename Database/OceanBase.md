
## 安装
1. 软件安装包可在 [OceanBase 软件下载中心](https://www.oceanbase.com/softwarecenter) 进行下载, 建议使用 `OceanBase All in One` 离线安装包
2. 解压 `OceanBase All in One` 安装包
3. 执行压缩包 `./bin/install.sh` shell 安装 `obd` (OceanBase Deployer，OceanBase 安装部署工具，简称为 obd)工具
4. 安装完 `obd` 后命令行执行 `obd web` 启动图形化界面, 在浏览器打开输出的web地址
5. 可视化安装步骤参考官方文档 [通过 obd 图形化界面部署 OceanBase 集群](https://www.oceanbase.com/docs/common-oceanbase-database-cn-1000000004236539#11-title-%E6%AD%A5%E9%AA%A4%E5%85%AD%EF%BC%9A%E9%83%A8%E7%BD%B2) 

## obd
列出所有部署
```bash
obd cluster list
```
查看 `myoceanbase` 集群
```bash
obd cluster display myoceanbase
```
启动 `myoceanbase` 集群
```bash
obd cluster start myoceanbase
```
关闭 `myoceanbase` 集群
```bash
obd cluster stop myoceanbase
```

## 常规使用

获取集群中的 Zone 信息
```sql
SELECT * FROM oceanbase.DBA_OB_ZONES;
```
获取集群中的所有节点信息
```sql
SELECT * FROM oceanbase.DBA_OB_SERVERS;
```
查看集群配置项
```sql
SELECT * FROM GV$OB_PARAMETERS WHERE NAME LIKE '%syslog_level%';
```


### 租户
>[!Abstract] 在系统租户下执行
>可以在obshell里进行可视化操作 (obd cluster display 集群名称 输出内容可看到web地址信息)

> 创建租户的流程
1. 创建资源规格
2. 创建资源池 绑定 资源规格
3. 创建租户 绑定 资源池
#### 资源规格
获取已有的资源规格信息
```sql
SELECT * FROM oceanbase.DBA_OB_UNIT_CONFIGS;
```
删除资源规格
```sql
DROP RESOURCE UNIT S1_unit_config;
```
创建一个名称为 `S1_unit_config` 的资源规格
```sql
CREATE RESOURCE UNIT S1_unit_config
                MEMORY_SIZE = '3G',
                MAX_CPU = 3, MIN_CPU = 3,
                LOG_DISK_SIZE = '6G',
                MAX_IOPS = 10000, MIN_IOPS = 10000, IOPS_WEIGHT=1;
```
修改资源单元 unit1 的示例如下
```sql
ALTER RESOURCE UNIT S1_unit_config 
	MAX_CPU 3, MIN_CPU 3, 
	MEMORY_SIZE '2G', 
	LOG_DISK_SIZE '2G', 
	IOPS_WEIGHT 3, 
	NET_BANDWIDTH_WEIGHT 3;
```

#### 资源池
获取资源池的配置信息
```sql
SELECT * from oceanbase.DBA_OB_RESOURCE_POOLS;
```
创建一个名为 `mq_pool_01` 的资源池
```sql
CREATE RESOURCE POOL mq_pool_01 
                UNIT='S1_unit_config', 
                UNIT_NUM=1, 
                ZONE_LIST=('zone1'); 
```
删除资源池
```sql
DROP RESOURCE POOL mq_pool_01;
```

#### 租户
查看所有的租户信息
```sql
SELECT * FROM oceanbase.DBA_OB_TENANTS;
```
删除租户
```sql
DROP TENANT mq_t1;
```
创建租户
```sql
CREATE TENANT IF NOT EXISTS mq_t1 
                PRIMARY_ZONE='zone1', 
                RESOURCE_POOL_LIST=('mq_pool_01')
                set OB_TCP_INVITED_NODES='%';
```
登录 mq_t1 租户的 root 用户 (docker mini 模式部署时 -u参数不需要加 #myoceanbase)
```bash
obclient -h127.0.0.1 -P2881 -uroot@mq_t1#myoceanbase -A
```
修改 root 用户的密码
```sql
ALTER USER root IDENTIFIED BY 'xxxx'; -- xxxx 为新密码
```
密码登录 mq_t1 租户的 root 用户
```bash
obclient -h127.0.0.1 -P2881 -uroot@mq_t1#myoceanbase -pxxxx  -- xxxx 为刚刚的新密码
```

### 数据库
>[!Abstract] 在刚刚创建的 mq_t1 租户下执行

创建数据库
```sql
CREATE DATABASE db1 CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_bin'; 
-- utf8mb4_bin: 区分大小写字母, 使用二进制排序规则
-- utf8mb4_general_ci: 不区分大小写, 使用通用排序规则
```

### 用户
>[!Abstract] 在刚刚创建的 mq_t1 租户下执行

创建用户
```sql
CREATE USER 'user1' IDENTIFIED BY 'password1';
```
用户授权
```sql
grant all privileges ON db1.* TO user1;

grant SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX, CREATE VIEW, SHOW VIEW ON db1.* TO user1;
```
查看用户权限
```sql
SHOW GRANTS FOR user1;
```
收回用户权限
```sql
REVOKE ALL PRIVILEGES, GRANT option FROM user1;
```

## 导入导出
在 [OceanBase 软件下载中心](https://www.oceanbase.com/softwarecenter) 页面 `迁移同步工具` 里下载 `OceanBase 导数工具` , 解压后将压缩包的 `bin` 目录配置到 `PATH` 环境变量中

导出 `xx` ,`xx2` 表结构(DDL)及数据
```bash
obdumper -h 127.0.0.1 -P 2881 -u user1@mq_t1 -p password1 -D db1 --table 'xx,xx2' --csv --ddl -f ./ --skip-check-dir

注:
--table '*' 则是导出所有表
--table 'xx,xx2' 替换成 --all 会导出库所有表及库用户信息, 此时 -u 需要替换成库 root@mq_t1 用户
```
>[!Warning] 导出涉及多个库时, 最好单独指定不同的 `-f` 路径, 防止 `obloader` 使用 `--table '*'` 时把所有库的表全部导入当前库

导入 `xx` ,`xx2` 表结构(DDL)及数据
```bash
obloader -h 127.0.0.1 -P 2881 -u user1@mq_t1 -p password1 -D db1 --table 'xx,xx2' --csv --ddl -f ./

--table '*' 则是导入 -f 目录下所有表
--table 'xx,xx2' 替换成 --all 会导入 -f 目录下所有表及库用户信息, 此时 -u 需要替换成库 root@mq_t1 用户
```
>[!Warning] 使用 `--table '*'` 时 `-f` 目录最好只有一个库的表数据
