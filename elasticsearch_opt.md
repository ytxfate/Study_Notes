Elasticsearch 集群搭建

# 一. JDK安装

略

# 二. ES 集群安装

## 0 环境配置

1. 本次集群安装使用 3 台主机, 同时将下列配置写入 `/etc/hosts`文件中

    ```
    # ip	hostname
    192.0.0.11	es_node1
    192.0.0.12	es_node2
    192.0.0.13	es_node3
    ```

2. `/etc/security/limits.conf` 文件 (注销登录生效) (<font style="color:red">CentOS7.4测试通过</font>)

    ```
    * soft nofile 65535
    * hard nofile 65535
    * soft nproc 2048
    * hard nproc 4096
    ```

3. 修改最大虚拟内存太小

   `/etc/sysctl.conf`文件添加下面配置：

   ```
   vm.max_map_count=655360
   ```

## 1 下载 es (本地测试使用 7.15.1)

[elasticsearch 下载地址](https://www.elastic.co/cn/downloads/elasticsearch)

## 2 安装 es

### 1 解压 

将 下载的压缩包`elasticsearch-7.15.1-linux-x86_64.tar.gz`拷到 3台主机上的 `/opt`目录下,有使用`tar -zxvf elasticsearch-7.15.1-linux-x86_64.tar.gz`解压,并将解压出来的文件目录统一改成`elasticsearch`

### 2 建数据及日志存储目录

在`elasticsearch`目录里建两个目录 `es_data` 和`es_log`,分别用于存储数据和日志

> `es_data` 对应配置文件中的`path.data`

> `es_log` 对应配置文件中的`path.logs`

### 3 修改`elasticsearch`的配置文件(`config/elasticsearch.yml`)

es_node1: 

```yml
# ======================== Elasticsearch Configuration =========================
#
# NOTE: Elasticsearch comes with reasonable defaults for most settings.
#       Before you set out to tweak and tune the configuration, make sure you
#       understand what are you trying to accomplish and the consequences.
#
# The primary way of configuring a node is via this file. This template lists
# the most important settings you may want to configure for a production cluster.
#
# Please consult the documentation for further information on configuration options:
# https://www.elastic.co/guide/en/elasticsearch/reference/index.html
#
# ---------------------------------- Cluster -----------------------------------
# 不要在该文件中设置索引相关配置
cluster.name: es_cluster_t # 设置集群名比较重要！
# ------------------------------------ Node ------------------------------------
node.name: es_node1 # 配置节点名
node.master: true # 是否有资格被选举为master，ES默认集群中第一台机器为主节点
node.data: true # 是否存储索引数据，默认 true，大集群中推荐一个角色一个类节点，不要身兼多职
# node.ingest: false #默认情况下所有节点均可以做ingest节点
# ----------------------------------- Paths ------------------------------------
#path.conf: /opt/elasticsearch/config # 设置配置文件存储路径，默认是es根目录下的config目录
path.data: /opt/elasticsearch/es_data # 设置索引数据存储路径，默认是es根目录下的data目录
path.logs: /opt/elasticsearch/es_log # 设置日志文件存储路径，默认是es根目录下的log目录
# ----------------------------------- Memory -----------------------------------
bootstrap.memory_lock: false # 锁住内存不进行swapping，避免系统内存不够时压制JVM虚拟内存
# ---------------------------------- Network -----------------------------------
network.host: es_node1 # 同时设置bind_host 和 publish_host
network.bind_host: 0.0.0.0 # 设置节点绑定ip，可用于http访问
network.publish_host: es_node1 # 设置其他节点与该节点交互ip，可以使内网ip单必须是真实ip
# Set a custom port for HTTP:
http.port: 9200 # 设置对外服务http端口
transport.tcp.port: 9300 # 设置节点之间交互的tcp端口
transport.tcp.compress: true # 设置是否压缩tcp传输时的数据，默认为false
# --------------------------------- Discovery ----------------------------------
#
# Pass an initial list of hosts to perform discovery when this node is started:
# The default list of hosts is ["127.0.0.1", "[::1]"]
#
discovery.seed_hosts: ["es_node1:9300", "es_node2:9300","es_node3:9300"]
# 集群各节点IP地址，也可以使用els、els.shuaiguoxia.com等名称，需要各节点能够解析
#
# Bootstrap the cluster using an initial set of master-eligible nodes:
#
cluster.initial_master_nodes: ["es_node1"]
discovery.zen.minimum_master_nodes: 2  # 为了避免脑裂，集群节点数最少为 半数+1
# For more information, consult the discovery and cluster formation module documentation.
# ---------------------------------- Gateway -----------------------------------
gateway.recover_after_nodes: 3 # 设置集群中N个节点启动时进行数据恢复，默认为1
# ---------------------------------- Various -----------------------------------
#
# Require explicit names when deleting indices:
#
#action.destructive_requires_name: true
bootstrap.system_call_filter: false
http.cors.allow-origin: "*"
http.cors.enabled: true
http.cors.allow-headers : X-Requested-With,X-Auth-Token,Content-Type,Content-Length,Authorization
http.cors.allow-credentials: true
```

es_node2 不同于 es_node1的地发如下:

```yml
node.name: es_node2
network.host: es_node2
network.publish_host: es_node2
```

es_node3 不同于 es_node1的地发如下:

```yml
node.name: es_node3
network.host: es_node3
network.publish_host: es_node3
```

>  Node节点组合
>
>  1. 主节点+数据节点(master+data):节点**即有称为主节点的资格，又存储数据**
>
>  	```
>	node.master: true
>  	node.data: true
>  	```
>  
>  2. 数据节点(data):节点没有成为主节点的资格，**不参与选举，只会存储数据**
>
>  	```
>	node.master: false
>  	node.data: true
>	```
>  
>  3. 客户端节点(client):不会成为主节点，也不会存储数据，主要是针对海量请求的时候，可以进行**负载均衡**
>  
>  	```
>	node.master: false
>  	node.data: false
>	```

### 4 启动

依次在3台主机的`elasticsearch`目录下使用`./bin/elasticsearch -d`启动ES

### 5 检查

推荐工具:

1. [cerebro](https://github.com/lmenezes/cerebro)检查各节点情况

   配置文件`conf/application.conf`连接配置如下

   ```
   # A list of known hosts
   hosts = [
     {
       host = "http://es_node1:9200",
       name = "es_cluster_t"
     },
     {
       host = "http://es_node2:9200",
       name = "es_cluster_t"
     },
     {
       host = "http://es_node3:9200",
       name = "es_cluster_t"
     }
   ]
   ```

2. [elasticHD](https://github.com/qax-os/ElasticHD)查询数据

   连接地址实例: `http://user:password@host:port`
   
3. [kibana](https://www.elastic.co/cn/downloads/kibana)

   配置文件`config/kibana.yml`

   ```yml
   server.name: "kibana"
   server.host: "0"
   elasticsearch.hosts: [ "http://es_node1:9200","http://es_node2:9200","http://es_node3:9200"]
   monitoring.ui.container.elasticsearch.enabled: true
   elasticsearch.username: "kibana_system"
   elasticsearch.password: "pwd"
   ```

## 3 配置用户名和密码

### 1 生成证书

在`elasticsearch`目录下执行如下命令:

```bash
./bin/elasticsearch-certutil cert -out ./config/elastic-certificates.p12 -pass ""
```

>  证书只能放在`config`目录下

### 2 将证书拷贝到另外的主机上

### 3 修改`elasticsearch`的配置文件(`config/elasticsearch.yml`)

添加如下配置

```
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: /opt/elasticsearch/config/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: /opt/elasticsearch/config/elastic-certificates.p12
```

### 4 设置密码

```
# 自动生成好几个默认用户和密码
./bin/elasticsearch-setup-passwords auto
# 手动生成密码
./bin/elasticsearch-setup-passwords interactive 
```







