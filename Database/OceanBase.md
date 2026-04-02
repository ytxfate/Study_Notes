
## 安装

### obd 单机
1. 软件安装包可在 [OceanBase 软件下载中心](https://www.oceanbase.com/softwarecenter) 进行下载, 建议使用 `OceanBase All in One` 离线安装包
2. 解压 `OceanBase All in One` 安装包
3. 执行压缩包 `./bin/install.sh` shell 安装 `obd` (OceanBase Deployer，OceanBase 安装部署工具，简称为 obd)工具
4. 安装完 `obd` 后命令行执行 `obd web` 启动图形化界面, 在浏览器打开输出的web地址
5. 可视化安装步骤参考官方文档 [通过 obd 图形化界面部署 OceanBase 集群](https://www.oceanbase.com/docs/common-oceanbase-database-cn-1000000004236539#11-title-%E6%AD%A5%E9%AA%A4%E5%85%AD%EF%BC%9A%E9%83%A8%E7%BD%B2) 
### obd 多 zone 集群
obd安装步骤参考 [[#obd 单机|obd 单机]] 步骤 1 ~ 3
`deploy.yaml` 文件参考官方 [mini-distributed-with-obproxy-example.yaml](https://github.com/oceanbase/obdeploy/blob/master/example/mini-distributed-with-obproxy-example.yaml) , 本次演示在单机上部署多zone集群
> password 结尾的几个字段需按实际修改
```yaml
## Only need to configure when remote login is required
user:
  username: 'xxx'
  password: 'xxx'
#   key_file: your ssh-key file path if need
#   port: your ssh port, default 22
#   timeout: ssh connection timeout (second), default 30
oceanbase-ce:
  servers:
    - name: server1
      # Please don't use hostname, only IP can be supported
      ip: 127.0.0.1
    - name: server2
      ip: 127.0.0.1
  global:
    # Starting from observer version 4.2, the network selection for the observer is based on the 'local_ip' parameter, and the 'devname' parameter is no longer mandatory.
    # If the 'local_ip' parameter is set, the observer will first use this parameter for the configuration, regardless of the 'devname' parameter.
    # If only the 'devname' parameter is set, the observer will use the 'devname' parameter for the configuration.
    # If neither the 'devname' nor the 'local_ip' parameters are set, the 'local_ip' parameter will be automatically assigned the IP address configured above.
    # devname: eth0
    cluster_id: 1
    # please set memory limit to a suitable value which is matching resource. 
    memory_limit: 6G # The maximum running memory for an observer
    system_memory: 1G # The reserved system memory. system_memory is reserved for general tenants. The default value is 30G.
    datafile_size: 2G # Size of the data file. 
    datafile_next: 2G # the auto extend step. Please enter an capacity, such as 2G
    datafile_maxsize: 20G # the auto extend max size. Please enter an capacity, such as 20G
    log_disk_size: 14G # The size of disk space used by the clog files.
    cpu_count: 5
    production_mode: false
    enable_syslog_wf: false # Print system logs whose levels are higher than WARNING to a separate log file. The default value is true.
    max_syslog_file_count: 4 # The maximum number of reserved log files before enabling auto recycling. The default value is 0.
    # Cluster name for OceanBase Database. The default value is obcluster. When you deploy OceanBase Database and obproxy, this value must be the same as the cluster_name for obproxy.
    appname: obcluster
    root_password: 'xxx' # root user password
    proxyro_password: 'xxx' # proxyro user pasword, consistent with obproxy's observer_sys_password, can be empty
  server1:
    mysql_port: 12881 # External port for OceanBase Database. The default value is 2881. DO NOT change this value after the cluster is started.
    rpc_port: 12882 # Internal port for OceanBase Database. The default value is 2882. DO NOT change this value after the cluster is started.
    obshell_port: 12886 # Operation and maintenance port for Oceanbase Database. The default value is 2886. This parameter is valid only when the version of oceanbase-ce is 4.2.2.0 or later.
    # The working directory for OceanBase Database. OceanBase Database is started under this directory. This is a required field.
    home_path: '/oceanbase-4.4.2-cluster/cluster01/obcluster'
    # The directory for data storage. The default value is $home_path/store.
    data_dir: '/oceanbase-4.4.2-cluster/cluster01/data'
    # The directory for clog, ilog, and slog. The default value is the same as the data_dir value.
    redo_dir: '/oceanbase-4.4.2-cluster/cluster01/redo'
    zone: zone1
  server2:
    mysql_port: 22881 # External port for OceanBase Database. The default value is 2881. DO NOT change this value after the cluster is started.
    rpc_port: 22882 # Internal port for OceanBase Database. The default value is 2882. DO NOT change this value after the cluster is started.
    obshell_port: 22886 # Operation and maintenance port for Oceanbase Database. The default value is 2886. This parameter is valid only when the version of oceanbase-ce is 4.2.2.0 or later.
    #  The working directory for OceanBase Database. OceanBase Database is started under this directory. This is a required field.
    home_path: '/oceanbase-4.4.2-cluster/cluster02/obcluster'
    # The directory for data storage. The default value is $home_path/store.
    data_dir: '/oceanbase-4.4.2-cluster/cluster02/data'
    # The directory for clog, ilog, and slog. The default value is the same as the data_dir value.
    redo_dir: '/oceanbase-4.4.2-cluster/cluster02/redo'
    zone: zone2
obproxy-ce:
  # Set dependent components for the component.
  # When the associated configurations are not done, OBD will automatically get the these configurations from the dependent components.
  depends:
    - oceanbase-ce
  servers:
    - 127.0.0.1
  global:
    listen_port: 12883 # External port. The default value is 2883.
    prometheus_listen_port: 12884 # The Prometheus port. The default value is 2884.
    rpc_listen_port: 12885
    home_path: '/oceanbase-4.4.2-cluster/obproxy01'
    # oceanbase root server list
    # format: ip:mysql_port;ip:mysql_port. When a depends exists, OBD gets this value from the oceanbase-ce of the depends.
    rs_list: '127.0.0.1:12881;127.0.0.1:22881'
    enable_cluster_checkout: false
    # observer cluster name, consistent with oceanbase-ce's appname. When a depends exists, OBD gets this value from the oceanbase-ce of the depends.
    cluster_name: obcluster
    skip_proxy_sys_private_check: true
    enable_strict_kernel_release: false
    obproxy_sys_password: 'xxx' # obproxy sys user password, can be empty. When a depends exists, OBD gets this value from the oceanbase-ce of the depends.
    observer_sys_password: 'xxx' # proxyro user pasword, consistent with oceanbase-ce's proxyro_password, can be empty. When a depends exists, OBD gets this value from the oceanbase-ce of the depends.
```
执行以下命令部署集群
```bash
obd cluster deploy obcluster -c deploy.yaml
```
部署完成后使用以下命令启动集群
```
obd cluster start obcluster
```
将输出以下内容:
```log
+----------------------------------------------+
|                 oceanbase-ce                 |
+-----------+---------+-------+-------+--------+
| ip        | version | port  | zone  | status |
+-----------+---------+-------+-------+--------+
| 127.0.0.1 | 4.4.2.0 | 12881 | zone1 | ACTIVE |
| 127.0.0.1 | 4.4.2.0 | 22881 | zone2 | ACTIVE |
+-----------+---------+-------+-------+--------+
obclient -h127.0.0.1 -P12881 -uroot@sys -p'xxx' -Doceanbase -A

cluster unique id: 2fd5c218-7bd6-5d24-aec3-79cd7cd00e37-19d4d122025-00020404

obshell program health check ok
display obshell dashboard ok
+------------------------------------------------------+
|                  obshell Dashboard                   |
+------------------------+------+-------------+--------+
| url                    | user | password    | status |
+------------------------+------+-------------+--------+
| http://127.0.1.1:12886 | root | 'xxx'       | active |
+------------------------+------+-------------+--------+

Connect to obproxy ok
+----------------------------------------------------------------+
|                           obproxy-ce                           |
+-----------+-------+-----------------+-----------------+--------+
| ip        | port  | prometheus_port | rpc_listen_port | status |
+-----------+-------+-----------------+-----------------+--------+
| 127.0.0.1 | 12883 | 12884           | 12885           | active |
+-----------+-------+-----------------+-----------------+--------+
obclient -h127.0.0.1 -P12883 -uroot@proxysys -p'xxx' -Doceanbase -A

obcluster running
```
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
修改配置
```
obd cluster edit-config myoceanbase
```
修改后根据提示执行以下命令使修改生效
```
obd cluster restart myoceanbase --wp
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
登录 mq_t1 租户的 root 用户
```bash
obclient -h127.0.0.1 -P2881 -uroot@mq_t1 -A
```
修改 root 用户的密码
```sql
ALTER USER root IDENTIFIED BY 'xxxx'; -- xxxx 为新密码
```
密码登录 mq_t1 租户的 root 用户
```bash
obclient -h127.0.0.1 -P2881 -uroot@mq_t1 -pxxxx  -- xxxx 为刚刚的新密码
```
#### 创建多副本租户
```sql
-- 创建资源规格
CREATE RESOURCE UNIT rs_unit_config
                MEMORY_SIZE = '3G',
                MAX_CPU = 3, MIN_CPU = 3,
                LOG_DISK_SIZE = '6G',
                MAX_IOPS = 10000, MIN_IOPS = 10000, IOPS_WEIGHT=1;

-- 创建资源池
CREATE RESOURCE POOL rs_pool
  UNIT = 'rs_unit_config', 
  UNIT_NUM = 1, 
  ZONE_LIST = ('zone1', 'zone2');

-- 创建租户
CREATE TENANT mysqlrs
  REPLICA_NUM = 2,
  PRIMARY_ZONE = 'zone1',
  RESOURCE_POOL_LIST = ('rs_pool')
  SET 
    ob_tcp_invited_nodes = '%',
    ob_compatibility_mode = 'mysql',
    recyclebin = 'off';
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

