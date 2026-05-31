
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
本次使用的配置如下, 修改了 `localAPIEndpoint.advertiseAddress` `nodeRegistration.criSocket` `nodeRegistration.name` `networking.serviceSubnet` 项, 添加 `controlPlaneEndpoint` `networking.podSubnet` 项
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
  podSubnet: 192.221.0.0/16
  serviceSubnet: 192.222.0.0/16
proxy: {}
controlPlaneEndpoint: "192.168.1.22:6443"
scheduler: {}
```
> [!Warning] 多控制节点集群时 controlPlaneEndpoint 必须设置

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
sudo kubeadm init --config kubeadm-config.yaml --upload-certs

# --upload-certs 上传证书到ETCD
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
```bash
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
##### 控制平面节点开启pod调用
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
##### 节点操作
1. 添加node节点 (在工作节点操作)
在主节点生成 worker 节点的 join 命令, 之后在 worker 节点执行 join 命令
worker 节点只需要安装 `kubeadm` `kubelet` `Docker` `cri-dockerd` 
```bash
kubeadm token create --print-join-command

创建一个永不过期的token
kubeadm token create --ttl 0 --print-join-command
```
2. 删除节点 (在主节点操作)
```bash
kubectl delete node xxx
```
3. 添加控制节点
```bash
# 在现有的控制节点上执行以下命令，上传证书到ETCD, 并会生成一个证书密钥, 即后文中的 <certificate-key>
kubeadm init phase upload-certs --upload-certs

# 在现有的控制节点上执行以下命令，生成加入集群所需的 Token
kubeadm token create --print-join-command

# 在新加入的控制节点上执行从上一步得到的命令，并加上 --control-plane 和 --certificate-key 参数
kubeadm join <master-ip>:<port> --token <token> --discovery-token-ca-cert-hash sha256:<hash> --control-plane --certificate-key <certificate-key>

# 查看新加入的节点
kubectl get node -A

# 重新平衡 CoreDNS Pod (建议执行)
kubectl -n kube-system rollout restart deployment coredns
```
> [!Warning] 添加控制节点集群时注意原集群需要有 controlPlaneEndpoint 配置, 不然会报错 unable to add a new control plane instance to a cluster that doesn't have a stable controlPlaneEndpoint address
##### YAML 模板
基本资源相关的创建都可以在命令末尾添加 `-o yaml --dry-run=client` 来获取模板
```bash
# 命名空间
kubectl create namespace nginx-ns -o yaml --dry-run=client
# pod
kubectl run nginx --image nginx:1.21.4 -n nginx-ns -o yaml --dry-run=client
# deployment
kubectl create deployment nginx-deploy --image=nginx:1.21.4 -n nginx-ns -o yaml --dry-run=client

# --dry-run=client：只生成配置，不向集群提交创建请求
```
##### namespaces
1. 查看命名空间
```bash
# 查询
kubectl get namespaces
kubectl get ns

# 查看命名空间详情
kubectl describe namespace nginx
```
2. 创建
- 命令行
```bash
kubectl create namespace xxx
```
- YAML
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nginx-ns
```
```bash
kubectl create -f xxx.yaml
kubectl apply -f xxx.yaml
# 区别:
#	create 仅在没有时创建, 否则报错
#   apply  没有则创建, 有则更新
```
3. 删除
- 命令行
```bash
kubectl delete namespace xxx
```
- YAML
```bash
kubectl delete -f xxx.yaml
```
##### pod
1. 创建
- 命令行
```bash
kubectl run mynginx --image nginx:1.21.4 -n nginx-ns
```
- YAML
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: mynginx
  name: mynginx
  namespace: nginx-ns
spec:
  containers:
  - name: nginx
    image: nginx:1.21.4
    ports:
    - containerPort: 80
```
```bash
kubectl apply -f xxx.yaml
```
2. 查看pod
```bash
kubectl get pod -A

# 查看 nginx-ns 命名空间下的 pod
kubectl get pod -n nginx-ns
kubectl get pod -n nginx-ns -o wide
```
3. 查看pod描述(用此命令查看容器事件)
```bash
kubectl describe pod mynginx -n nginx-ns
```
4. 删除
```bash
kubectl delete pod mynginx -n nginx-ns
```
- YAML
```bash
kubectl delete -f xxx.yaml
```
5. 进入容器
```bash
kubectl exec -it mynginx -n nginx-ns -- bash

# pod 下有多个容器需要使用 -c 指定具体的容器
kubectl exec -it mynginx -n nginx-ns -c nginx -- bash
```
6. 查看 pod 日志
```bash
kubectl logs nginx-deploy-846447d89f-l97xz -n nginx-ns
```
##### deployment
1. 创建
- 命令行
```bash
kubectl create deployment nginx-deploy --image=nginx:1.21.4 -n nginx-ns
```
- YAML
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deploy
  name: nginx-deploy
  namespace: nginx-ns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deploy
  template:
    metadata:
      labels:
        app: nginx-deploy
    spec:
      containers:
      - image: nginx:1.21.4
        name: nginx
```
```bash
kubectl apply -f xxx.yaml
```
2. 查看deployment信息
```bash
kubectl get deployments -n nginx-ns
``` 
3. 删除deployment
- 命令行
```bash
kubectl delete deployment nginx-deploy -n nginx-ns
```
- YAML
```bash
kubectl delete -f xxx.yaml
```
4. 扩容/缩容
```bash
kubectl scale --replicas=5 deployment nginx-deploy -n nginx-ns
```
5. 滚动升级
```bash
kubectl set image deployment nginx-deploy -n nginx-ns nginx=nginx:1.22
```
6. 更新一个资源的注解 (建议 滚动升级 后添加, 方便查看区分滚动更新历史)
```bash
kubectl annotate deployment nginx-deploy kubernetes.io/change-cause="update nginx image version" -n nginx-ns
```
7. 滚动更新历史
```bash
kubectl rollout history deployment nginx-deploy -n nginx-ns
```
8. 回滚
```bash
# 回滚到上一个版本
kubectl rollout undo deployment nginx-deploy -n nginx-ns

# 回滚到指定版本 (--to-revision 后的值为 rollout history 查询到的值)
kubectl rollout undo deployment nginx-deploy -n nginx-ns --to-revision=1
```
##### services
- ClusterIP (默认)
通过集群的内部 IP 公开 Service, 选择该值时 Service 只能够在集群内部访问
- NodePort
通过每个节点上的 IP 和静态端口（NodePort）公开 Service
- LoadBalancer
使用云平台的负载均衡器向外部公开 Service (Kubernetes 不直接提供负载均衡组件)
- ExternalName
将服务映射到 externalName 字段的内容（例如，映射到主机名 api.foo.bar.example）。 该映射将集群的 DNS 服务器配置为返回具有该外部主机名值的 CNAME 记录。 集群不会为之创建任何类型代理。

1. 创建
- 命令行
```bash
kubectl expose deployment nginx-deploy -n nginx-ns --name nginx-service --port 80 --type=NodePort
```
- YAML
```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-deploy
  name: nginx-service
  namespace: nginx-ns
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-deploy
  type: NodePort
```
```bash
kubectl apply -f xxx.yaml
```
2. 查询
```bash
kubectl get service -n nginx-ns
```
3. 删除
```bash
kubectl delete service nginx-service -n nginx-ns
```
4. 查看 service 详情
```bash
kubectl describe service nginx-service -n nginx-ns
```
##### volumes
1. nginx 挂载本地目录
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nginx-ns
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deploy
  name: nginx-deploy
  namespace: nginx-ns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deploy
  template:
    metadata:
      labels:
        app: nginx-deploy
    spec:
      containers:
      - image: nginx:1.21.4
        ports:
        - containerPort: 80
        name: nginx
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        hostPath:
          path: /opt/web    # 目录自行创建
          type: Directory
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-deploy
  name: nginx-service
  namespace: nginx-ns
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 31000
  selector:
    app: nginx-deploy
  type: NodePort
```
2. nginx 挂载nfs目录
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nginx-ns
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deploy
  name: nginx-deploy
  namespace: nginx-ns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deploy
  template:
    metadata:
      labels:
        app: nginx-deploy
    spec:
      containers:
      - image: nginx:1.21.4
        ports:
        - containerPort: 80
        name: nginx
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        nfs:
          server: 192.168.1.22  # nfs 服务自行搭建
          path: /opt/web        # 目录自行创建
          type: Directory
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-deploy
  name: nginx-service
  namespace: nginx-ns
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 31000
  selector:
    app: nginx-deploy
  type: NodePort
```
其他类型挂载参考官方文档 [volumes](https://v1-35.docs.kubernetes.io/zh-cn/docs/concepts/storage/volumes/) 或最新版本的文档 [volumes](https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/) 
###### pv
1. 创建
- hostPath
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv01-10m
spec:
  capacity:
    storage: 10M
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain     # 手动回收 (默认)
  hostPath:
    path: /opt/web/01    # 目录自行创建
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv02-1gi
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle     # 简单擦除（rm -rf /thevolume/*）已经废弃
  hostPath:
    path: /opt/web/02    # 目录自行创建
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv03-3gi
spec:
  capacity:
    storage: 3Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Delete     # 删除存储卷
  hostPath:
    path: /opt/web/03    # 目录自行创建
```
- nfs
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv01-10m
spec:
  capacity:
    storage: 10M
  accessModes:
    - ReadWriteMany
  storageClassName: nfs
  nfs:
    server: 192.168.1.22
    path: /opt/web/01    # 目录自行创建
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv02-1gi
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  storageClassName: nfs
  nfs:
    server: 192.168.1.22
    path: /opt/web/02    # 目录自行创建
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv03-3gi
spec:
  capacity:
    storage: 3Gi
  accessModes:
    - ReadWriteMany
  storageClassName: nfs
  nfs:
    server: 192.168.1.22
    path: /opt/web/03    # 目录自行创建
```

```bash
kubectl apply -f xxx.yaml
```
2. 查询
```bash
kubectl get pv
```
3. 查看详情
```bash
kubectl describe pv pv01-10m
```
4. 删除
```bash
kubectl delete pv pv01-10m
```
###### pvc
1. 创建
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
  namespace: nginx-ns
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: "" # 此处须显式设置空字符串，否则会被设置为默认的 StorageClass
  resources:
    requests:
      storage: 200Mi
```

```bash
kubectl apply -f xxx.yaml
```
2. 查询
```bash
kubectl get pvc -n nginx-ns
```
3. 查看详情
```bash
kubectl describe pvc nginx-pvc -n nginx-ns
```
4. 挂载
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deploy
  name: nginx-deploy
  namespace: nginx-ns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-deploy
  template:
    metadata:
      labels:
        app: nginx-deploy
    spec:
      containers:
      - image: nginx:1.21.4
        ports:
        - containerPort: 80
        name: nginx
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        persistentVolumeClaim:
          claimName: nginx-pvc
```
5. 删除
```bash
kubectl delete pvc nginx-pvc -n nginx-ns
```
##### ConfigMap
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: busybox-ns
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: busybox-cm
  namespace: busybox-ns
data:
  # 类属性键；每一个键都映射到一个简单的值
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"

  # 类文件键
  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-env-configmap
  namespace: busybox-ns
spec:
  containers:
    - name: busybox-env
      command: ["/bin/sh", "-c", "printenv"]
      image: busybox:latest
      envFrom:
        - configMapRef:  # data 里的内容全部设置到环境变量里
            name: busybox-cm
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-env-part-configmap
  namespace: busybox-ns
spec:
  containers:
    - name: busybox-env-part
      command: ["/bin/sh", "-c", "printenv"]
      image: busybox:latest
      env:
        # 定义环境变量
        - name: PLAYER_INITIAL_LIVES # 请注意这里和 ConfigMap 中的键名是不一样的
          valueFrom:
            configMapKeyRef:
              name: busybox-cm           # 这个值来自 ConfigMap
              key: player_initial_lives  # 需要取值的键
        - name: UI_PROPERTIES_FILE_NAME
          valueFrom:
            configMapKeyRef:
              name: busybox-cm
              key: ui_properties_file_name
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-file-configmap
  namespace: busybox-ns
spec:
  containers:
    - name: busybox-file
      command: ["/bin/sh", "-c", "ls -al /etc/foo && cat /etc/foo/game.properties"]
      image: busybox:latest
      volumeMounts:
      - name: foo
        mountPath: "/etc/foo"
        readOnly: true
  volumes:
  - name: foo
    configMap:     # data 里的内容全部写入到各自key文件里
      name: busybox-cm
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox-file-part-configmap
  namespace: busybox-ns
spec:
  containers:
    - name: busybox-file-part
      command: ["/bin/sh", "-c", "ls -al /etc/foo && cat /etc/foo/game.properties"]
      image: busybox:latest
      volumeMounts:
      - name: foo
        mountPath: "/etc/foo"
        readOnly: true
  volumes:
  - name: foo
    configMap:
      name: busybox-cm
      # 来自 ConfigMap 的一组键，将被创建为文件
      items:
      - key: "game.properties"
        path: "game.properties"
      - key: "user-interface.properties"
        path: "user-interface.properties"
```
##### Secret
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: busybox-ns
---
apiVersion: v1
kind: Secret
metadata:
  name: dotfile-secret
  namespace: busybox-ns
data:
  .secret-file: dmFsdWUtMg0KDQo=
---
apiVersion: v1
kind: Pod
metadata:
  name: secret-dotfiles-pod
  namespace: busybox-ns
spec:
  volumes:
    - name: secret-volume
      secret:
        secretName: dotfile-secret
  containers:
    - name: dotfile-test-container
      image: busybox:latest
      command: ["sh", "-c", "ls -al /etc/secret-volume && cat /etc/secret-volume/.secret-file"]
      volumeMounts:
        - name: secret-volume
          readOnly: true
          mountPath: "/etc/secret-volume"
```
##### gateway
安装 gateway-api
```bash
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml

# 查看
kubectl api-resources | grep gateway.networking.k8s.io
```
安装 nginx-gateway-fabric crds
```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.6.3/deploy/crds.yaml
```
使用 helm 安装 nginx-gateway-fabric
```bash
helm pull oci://ghcr.io/nginx/charts/nginx-gateway-fabric:2.6.3 --untar

cd nginx-gateway-fabric

helm install ngf . --create-namespace -n nginx-gateway --set nginx.service.type=LoadBalancer --set nginx.service.externalTrafficPolicy=Cluster --set nginxGateway.snippetsFilters.enable=true

kubectl get all -n nginx-gateway
kubectl get gatewayclass
```
创建一个测试服务
```bash
kubectl create namespace nginx-ns
kubectl create deployment nginx-deploy --image=nginx:1.21.4 -n nginx-ns --replicas=3
kubectl expose deployment nginx-deploy -n nginx-ns --name nginx-service --port 80
```
创建 Gateway
```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: nginx-gw
  namespace: nginx-ns
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
EOF

kubectl get all -n nginx-ns
kubectl get nginxproxy -n nginx-gateway
kubectl describe nginxproxy ngf-proxy-config -n nginx-gateway
```
创建 HTTPRoute
```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: nginx-httproute
  namespace: nginx-ns
spec:
  parentRefs:
  - name: nginx-gw
  hostnames:
  - nginx.example.com
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
      method: GET
    backendRefs:
    - name: nginx-service
      kind: Service
      port: 80
EOF

# nginx.example.com 绑定 service/nginx-gw-nginx EXTERNAL-IP
# service/nginx-gw-nginx EXTERNAL-IP 显示为 <pending> 或为空因为 Kubernetes 集群环境中缺少能够自动分配公网 IP 的负载均衡器（LoadBalancer）支持, 参考后文 metallb 部分

kubectl get httproute -n nginx-ns
```
卸载
```bash
helm uninstall ngf -n nginx-gateway

kubectl delete ns nginx-gateway

kubectl delete -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.6.3/deploy/crds.yaml
```
##### metallb 负载均衡器‌
部署
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.16.1/config/manifests/metallb-frr-k8s.yaml
```
配置IP地址池(Layer2模式)
```bash
kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:  # 预留IP段/范围
  - 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
EOF
```
##### 证书管理
```bash
# 检查证书何时过期
sudo kubeadm certs check-expiration

# 手动更新证书 (如果你运行的集群具有多副本的控制平面，则需要在所有控制平面节点上执行这条命令)
sudo kubeadm certs renew all
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

#### 使用
##### Headlamp (替代 Kubernetes Dashboard)
```bash
# 下载文件
curl -LO https://raw.github.com/kubernetes-sigs/headlamp/refs/tags/v0.42.0/kubernetes-headlamp.yaml

# 将配置应用于资源
kubectl apply -f kubernetes-headlamp.yaml

# 创建 service account
kubectl -n kube-system create serviceaccount headlamp-admin

# 为特定的ClusterRole创建ClusterRoleBinding
kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin

# 查看 service 的 ip 和 端口, 浏览器访问 http://{ip}:80
kubectl describe service headlamp -n kube-system

# 生成访问 token
kubectl create token headlamp-admin -n kube-system 
```

