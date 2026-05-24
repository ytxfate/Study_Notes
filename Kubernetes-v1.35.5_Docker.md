
#### 注意事项
本次演示使用以下版本软件

| 软件                      | 版本      |
| ----------------------- | ------- |
| Docker                  | 24.0.9  |
| cri-dockerd             | 0.3.25  |
| kubeadm,kubelet,kubectl | v1.35.5 |
| CNI                     | v1.3.0  |
| calico                  | v3.32.0 |

#### 安装 Docker
[install_docker-gitee](https://gitee.com/ytxfate/Study_Notes/blob/master/install_docker_on_centos7.md#install-docker-engine-from-binaries)
[install_docker-github](https://github.com/ytxfate/Study_Notes/blob/master/install_docker_on_centos7.md#install-docker-engine-from-binaries)
#### 安装 cri-dockerd
使用以下命令下载文件, 解压后将 `cri-dockerd` 可执行文件放到 `/usr/bin/` 目录下 
```bash
# 下载文件
curl -LO https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.25/cri-dockerd-0.3.25.amd64.tgz

# 解压文件
tar -zxf cri-dockerd-0.3.25.amd64.tgz

# 移动文件
sudo mv cri-dockerd/cri-dockerd /usr/bin/
```
通过以下命令下载 `service` 文件, 若上一步骤二进制文件不放 `/usr/bin/` 需要修改两个 `service` 文件中 `ExecStart` 的路径, 并将文件移动到 `/etc/systemd/system` 目录下
```bash
# 下载文件 (文末附件有文件内容)
curl -LO https://raw.github.com/Mirantis/cri-dockerd/refs/tags/v0.3.25/packaging/systemd/cri-docker.service
curl -LO https://raw.github.com/Mirantis/cri-dockerd/refs/tags/v0.3.25/packaging/systemd/cri-docker.socket

# 移动文件
sudo mv cri-docker.s* /etc/systemd/system/
```
重新加载 `systemd` 管理器, 并启动 `kubelet` 服务
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now cri-docker
```

#### 安装 CNI 插件
使用以下命令下载文件并解压文件到 `/opt/cni/bin` 下
```bash
# 下载文件
curl -LO "https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz"

# 创建目录
sudo mkdir -p /opt/cni/bin

# 解压文件到 /opt/cni/bin 目录下
sudo tar -zxf cni-plugins-linux-amd64-v1.3.0.tgz  -C /opt/cni/bin
```

#### 安装 kubeadm,kubelet,kubectl
通过以下命令获取二进制文件, 并使用 `chmod +x kube*` 赋予执行权限, 随后将文件移动到 `/usr/bin/` 目录下 
```bash
# 下载二进制文件
curl -L --remote-name-all https://dl.k8s.io/release/v1.35.5/bin/linux/amd64/{kubeadm,kubelet,kubectl}

# 赋予执行权限
chmod +x kube*

# 文件移动至 /usr/bin/ 下
sudo mv kube* /usr/bin/
```
通过以下命令下载 `service` 文件, 若上一步骤二进制文件不放 `/usr/bin/` 需要修改两个 `service` 文件中 `ExecStart` 的路径
`kubelet.service` 文件放 `/etc/systemd/system` 目录下
`10-kubeadm.conf` 文件放 `/etc/systemd/system/kubelet.service.d` 目录下
```bash
# 下载文件 (文末附件有文件内容)
curl -LO "https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubelet/kubelet.service"
curl -LO "https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf"

# 创建 kubelet.service.d 目录
sudo mkdir -p /etc/systemd/system/kubelet.service.d

# 移动文件
sudo mv kubelet.service /etc/systemd/system/
sudo mv 10-kubeadm.conf /etc/systemd/system/kubelet.service.d/
```
使用以下命令关闭 `swap`
```bash
sudo swapoff -a
```
重新加载 `systemd` 管理器, 并启动 `kubelet` 服务
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now kubelet
```

#### # kubeadm 创建集群
使用一下命令生成配置文件
```bash
kubeadm config print init-defaults > kubeadm-config.yaml
```
本次使用的配置如下, 修改了 `localAPIEndpoint.advertiseAddress` `nodeRegistration.criSocket` `nodeRegistration.name` `networking.serviceSubnet` 项
```yaml
apiVersion: kubeadm.k8s.io/v1beta4
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.1.22
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///run/cri-dockerd.sock
  imagePullPolicy: IfNotPresent
  imagePullSerial: true
  name: debian
  taints: null
timeouts:
  controlPlaneComponentHealthCheck: 4m0s
  discovery: 5m0s
  etcdAPICall: 2m0s
  kubeletHealthCheck: 4m0s
  kubernetesAPICall: 1m0s
  tlsBootstrap: 5m0s
  upgradeManifests: 5m0s
---
apiServer: {}
apiVersion: kubeadm.k8s.io/v1beta4
caCertificateValidityPeriod: 87600h0m0s
certificateValidityPeriod: 8760h0m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
encryptionAlgorithm: RSA-2048
etcd:
  local:
    dataDir: /var/lib/etcd
# imageRepository: registry.aliyuncs.com/google_containers
imageRepository: registry.k8s.io
kind: ClusterConfiguration
kubernetesVersion: 1.35.5
networking:
  dnsDomain: cluster.local
  serviceSubnet: 192.222.0.0/16
proxy: {}
scheduler: {}
```
使用以下命令查看需要使用到镜像并拉取镜像
```bash
# 查看
kubeadm config images list

# 拉取 (registry.k8s.io 大多数时候无法访问, 可使用下一步中的脚本下载文件或修改上一步中 imageRepository 项, 并加上 --config 来拉取文件)
kubeadm config images pull
kubeadm config images pull --config kubeadm-config.yaml
```
也可以将下列命令保存到 `shell` 脚本中来拉取文件
```bash
#!/bin/bash
images=(
    kube-apiserver:v1.35.5              # registry.k8s.io/kube-apiserver:v1.35.5
    kube-controller-manager:v1.35.5     # registry.k8s.io/kube-controller-manager:v1.35.5
    kube-scheduler:v1.35.5              # registry.k8s.io/kube-scheduler:v1.35.5
    kube-proxy:v1.35.5                  # registry.k8s.io/kube-proxy:v1.35.5
    coredns:v1.13.1                     # registry.k8s.io/coredns/coredns:v1.13.1 此镜像命名有变化
    pause:3.10.1                        # registry.k8s.io/pause:3.10.1
    etcd:3.6.6-0                        # registry.k8s.io/etcd:3.6.6-0
)


for imageName in ${images[@]} ; do
    echo $imageName
    docker pull registry.aliyuncs.com/google_containers/$imageName
    if [[ "$imageName" == coredns* ]]; then
        # echo "coredns/$imageName"
        docker tag registry.aliyuncs.com/google_containers/$imageName registry.k8s.io/coredns/$imageName
    else
        docker tag registry.aliyuncs.com/google_containers/$imageName registry.k8s.io/$imageName
        # echo "$imageName"
    fi
    docker rmi registry.aliyuncs.com/google_containers/$imageName
done
```
> [!warning] 本次演示发现 kubeadm init 时会未知原因启动不了镜像, 需要使用以下命令为镜像创建一个新标签, 并且两个相同的镜像需同时存在
```bash
docker tag registry.k8s.io/pause:3.10.1 registry.k8s.io/pause:3.10
```
初始化控制平面
```bash
sudo kubeadm init --config kubeadm-config.yaml
```
执行以下命令可使非 `root` 用户可以运行 `kubectl`
```bash
mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
若初始化失败,使用以下命令重置
```bash
sudo kubeadm reset -f && sudo rm -rf /etc/kubernetes /etc/cni/net.d $HOME/.kube/config && sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
```

#### 网络插件
使用以下命令下载文件
```
curl -LO https://raw.githubusercontent.com/projectcalico/calico/v3.32.0/manifests/calico.yaml
```
> 建议提前下载calico.yaml中涉及的镜像

使用以下命令添加网络插件
```bash
kubectl apply -f calico.yaml
 ```
 
#### 常用命令
##### 关机
```bash
# 标记节点为不可调度 (在master节点执行命令)
kubectl cordon <你的节点名>

# 驱逐节点服务
kubectl drain <节点名称> --delete-emptydir-data --force --ignore-daemonsets

# 关闭服务
sudo systemctl stop kubelet

# 停止控制平面节点所有 k8s 容器
docker stop $(docker container ls -f "name=^k8s" -q -a)

# 移除控制平面节点所有 k8s 容器 (关机恢复疑似不会使用之前的容器)
docker rm $(docker container ls -f "name=^k8s" -q -a)
```
##### 关机恢复
```bash
# 启动服务
sudo systemctl start kubelet

# 恢复节点调度
kubectl uncordon <你的节点名>
```
##### 移除 k8s 中 Exited 状态的容器
```bash
docker rm $(docker container ls -f "name=^k8s" -f "status=exited" -q -a)
```
##### 节点开启pod调用
1. master节点开启pod调用
```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```
2. 控制平面节点开启pod调用
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
##### 节点操作
1. 添加node节点 (在工作节点操作)
生成worker节点的join命令
```bash
kubeadm token create --print-join-command

创建一个永不过期的token
kubeadm token create --ttl 0 --print-join-command
```
2. 删除节点 (在主节点操作)
```bash
kubectl delete node xxx
```
##### pod
1. 查看pod
```bash
kubectl get pod -A
```
2. 查看pod描述(用此命令查看容器事件)
```bash
kubectl describe pod xxx -n xxx
```
##### namespaces
1. 查看命名空间
```bash
kubectl get namespaces
查看命名空间详情
kubectl describe namespace nginx
```
##### deployment
1. 查看deployment信息
```bash
kubectl get deployment -n xxx
``` 
2. 删除deployment
```bash
kubectl delete deployment xxx -n xxx
```
##### services
1. 查看services信息
```bash
kubectl get services -n xxx
```
2. 删除services
```bash
kubectl delete services xxx -n xxx
```

#### 附件
cri-docker.service
```
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint fd://
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
```

cri-docker.socket
```
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
```

kubelet.service
```
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
```

10-kubeadm.conf
```
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/sysconfig/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```
