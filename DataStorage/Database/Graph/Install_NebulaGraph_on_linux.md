# NebulaGraph 集群安装文档

## 零 备注

本次部署使用`3.5.0`版本`tar.gz`安装包进行演示

## 一 系统环境

### 1 配置信息

> 由于单机部署,所以端口号递增,多机部署可考虑使用同一个端口值

| IP地址    | 域名    | graphd | metad                         | storaged                          |
| --------- | ------- | ------ | ----------------------------- | --------------------------------- |
| 127.0.0.1 | nebula1 | 9111   | 9211<br />实际占用: 9211,9212 | 9311<br />实际占用:9310,9311,9312 |
| 127.0.0.1 | nebula2 | 9122   | 9222<br />实际占用:9222,9223  | 9322<br />实际占用:9321,9322,9323 |
| 127.0.0.1 | nebula3 | 9133   | 9233<br />实际占用:9233,9234  | 9333<br />实际占用:9332,9333,9334 |

> 需要将 `nebula1`, `nebula2`, `nebula3`添加到3个节点的`/etc/hosts`中

## 二 部署流程

> 此处仅列出配置差异部分, 剩余配置复用官方配置

### 1 配置信息

#### 1 节点1 (nebula1)

1. nebula-graphd.conf

   ```
   --meta_server_addrs=nebula1:9211,nebula2:9222,nebula3:9233
   --local_ip=nebula1
   --port=9111
   --ws_http_port=19669
   --ws_meta_http_port=19559
   --enable_authorize=true
   ```

2. nebula-metad.conf

   ```
   --meta_server_addrs=nebula1:9211,nebula2:9222,nebula3:9233
   --local_ip=nebula1
   --port=9211
   --ws_http_port=19559
   --ws_storage_http_port=19779
   ```

3. nebula-storaged.conf

   ```
   --meta_server_addrs=nebula1:9211,nebula2:9222,nebula3:9233
   --local_ip=nebula1
   --port=9311
   --ws_http_port=19779
   ```

#### 2 节点2 (nebula2)

1. nebula-graphd.conf

   ```
   --meta_server_addrs=nebula1:9211,nebula2:9222,nebula3:9233
   --local_ip=nebula2
   --port=9122
   --ws_http_port=19670
   --ws_meta_http_port=19560
   --enable_authorize=true
   ```

2. nebula-metad.conf

   ```
   --meta_server_addrs=nebula1:9211,nebula2:9222,nebula3:9233
   --local_ip=nebula2
   --port=9222
   --ws_http_port=19560
   --ws_storage_http_port=19780
   ```

3. nebula-storaged.conf

   ```
   --meta_server_addrs=nebula1:9211,nebula2:9222,nebula3:9233
   --local_ip=nebula2
   --port=9322
   --ws_http_port=19780
   ```

#### 3 节点3 (nebula3)

1. nebula-graphd.conf

   ```
   --meta_server_addrs=nebula1:9211,nebula2:9222,nebula3:9233
   --local_ip=nebula3
   --port=9133
   --ws_http_port=19671
   --ws_meta_http_port=19561
   --enable_authorize=true
   ```

2. nebula-metad.conf

   ```
   --meta_server_addrs=nebula1:9211,nebula2:9222,nebula3:9233
   --local_ip=nebula3
   --port=9233
   --ws_http_port=19561
   --ws_storage_http_port=19781
   ```

3. nebula-storaged.conf

   ```
   --meta_server_addrs=nebula1:9211,nebula2:9222,nebula3:9233
   --local_ip=nebula3
   --port=9333
   --ws_http_port=19781
   ```

### 2 启动

> 直接在节点安装目录执行以下命令启动所有服务

```bash
./scripts/nebula.service start all
```

### 3 检查

```bash
./scripts/nebula.service status all
```

###  4 添加`storaged`节点

> 使用`nebula-console`工具登录任意`graphd`节点
>
> 默认用户 `root`, 密码 `nebula`

```bash
./nebula-console-linux-amd64-v3.5.0 -addr 127.0.0.1 -port 9111 -u root -p nebula
```

>  登录成功使用以下命令添加`storaged`节点

```bash
add HOSTS "nebula1":9311,"nebula2":9322,"nebula3":9333
```

> 使用以下命令检查添加结果, 全部节点 `ONLINE`则正常

```bash
show HOSTS
```

### 5 关闭

```bash
./scripts/nebula.service stop all
```

