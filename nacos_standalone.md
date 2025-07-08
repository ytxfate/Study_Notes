
>[!Note] 本次安装使用 3.0.1 版本, 且为单机模式

##### 1 安装 java 运行环境
在 [OpenJDK](https://jdk.java.net/archive/) 页面下载 `JDK 17` 以上版本, 解压到任意位置, 无需配置 `JAVA_HOME` 等环境变量

##### 2 安装 Nacos
1. 在 [Nacos](https://nacos.io/download/nacos-server/) 页面下载 `3.0.1` 版本 `Nacos`, 也可直接到 [github](https://github.com/alibaba/nacos/releases) 上下载, `github` 发行包更丰富, 解压下载的发行包到任意位置
2. 编辑 `conf/application.properties` 配置认证, 修改以下部分配置即可
```
# 此行修改为true 开启客户端认证
nacos.core.auth.enabled=true

# JWT令牌的密钥
nacos.core.auth.server.identity.key={Base64编码的字符串且原始密钥长度不得低于32字符}

# 身份识别信息
nacos.core.auth.server.identity.value={Base64编码的字符串且原始密钥长度不得低于32字符}
nacos.core.auth.plugin.nacos.token.secret.key={Base64编码的字符串且原始密钥长度不得低于32字符}
```
3. 配置 `Nacos` 下启动脚本里的 `JAVA_HOME`
```bash
# 配置中找到类似的行, 并注释这几行
[ ! -e "$JAVA_HOME/bin/java" ] && JAVA_HOME=$HOME/jdk/bin/java
[ ! -e "$JAVA_HOME/bin/java" ] && JAVA_HOME=/usr/java
[ ! -e "$JAVA_HOME/bin/java" ] && JAVA_HOME=/opt/taobao/java
[ ! -e "$JAVA_HOME/bin/java" ] && unset JAVA_HOME

# 增加一行, 路径为 OpenJDK 解压的路径
JAVA_HOME=.../openjdk-17.0.0.1
```
4. 启动
```bash
# 在 Nacos 家目录使用此命令启动服务, 并查看 logs/startup.log 启动日志是否正常
./bin/startup.sh -m standalone
```
5. 停止
```bash
./bin/shutdown.sh
```
6. 配置 `service` 服务, 使用 `systemctl` 管理服务启停, 编辑 `/etc/systemd/system/nacos.service` 文件, 内容如下, `PATH_TO_NACOS` 修改为 `Nacos` 实际目录
```
[Unit]
Description=nacos
After=network.target

[Service]
Type=forking
# xxx 用户启动服务
User=xxx
ExecStart=PATH_TO_NACOS/bin/startup.sh -m standalone
ExecReload=PATH_TO_NACOS/bin/shutdown.sh
ExecStop=PATH_TO_NACOS/bin/shutdown.sh
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
执行 `systemctl daemon-reload` 重新加载 `service` 服务, 之后便可以使用 `systemctl` 管理服务
7. 服务主要有以下端口, 可在 `conf/application.properties` 中进行修改

|端口|与主端口的偏移量|描述|
|---|---|---|
|8848|0|Nacos HTTP API 端口，用于Nacos AdminAPI及HTTP OpenAPI的访问|
|9848|1000|客户端gRPC请求服务端端口，用于客户端向服务端发起连接和请求|
|9849|1001|服务端gRPC请求服务端端口，用于服务间同步等|
|7848|-1000|Jraft请求服务端端口，用于处理服务端间的Raft相关请求|
|8080|独立配置|Nacos控制台端口，访问Nacos控制台及Nacos控制台的API|
