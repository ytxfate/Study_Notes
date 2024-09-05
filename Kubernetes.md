
>[!Warning] 注意事项
>安装文档参考: https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
>kubeadm、kubelet、kubectl 使用 v1.21.6 版本

### 1 安装 CNI 插件
> 本次测试使用 amd64 架构的 v0.8.2 版本
1. 下载插件
```bash
curl -L "https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz" --output cni-plugins-linux-amd64-v0.8.2.tgz
```
2. 创建目录
```bash
mkdir /opt/cni/bin -p
```
3. 解压插件
```bash
tar -zxf cni-plugins-linux-amd64-v0.8.2.tgz -C /opt/cni/bin
```
### 2 安装 `kubeadm`、`kubelet`、`kubectl` 并添加 `kubelet` 系统服务
1. 下载 `kubeadm`,`kubelet` 及系统服务文件
```bash
curl -L --remote-name-all https://dl.k8s.io/release/v1.21.6/bin/linux/amd64/{kubeadm,kubelet}

chmod +x {kubeadm,kubelet}

curl -sSL "https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubelet/kubelet.service" --output kubelet.service

curl -sSL "https://raw.githubusercontent.com/kubernetes/release/v0.16.2/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" --output 10-kubeadm.conf
```
> 本次测试系统服务文件如下:
> [[kubelet.service]]
> [[10-kubeadm.conf]]
2. 文件移动到对应的目录
```bash
mv kubeadm /usr/bin/
mv kubelet /usr/bin/
mv kubelet.service /etc/systemd/system/
mkdir /etc/systemd/system/kubelet.service.d
mv 10-kubeadm.conf /etc/systemd/system/kubelet.service.d/
```
3. 安装 kubectl
安装文档参考: https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/
```bash
curl -LO "https://dl.k8s.io/release/v1.21.6/bin/linux/amd64/kubectl"
mv kubectl /usr/bin/

查看版本
kubectl version --client
```
### 3 启动k8s
1. 关闭swap
```bash
swapoff -a
```
2. 启动 kubelet
```bash
systemctl enable --now kubelet
```
> kubelet 现在每隔几秒就会重启，因为它陷入了一个等待 kubeadm 指令的死循环
3. 下载镜像
```bash
kubeadm config images list
```
将下列命令保存到文本中, 然后拉取镜像
```bash
#!/bin/bash
images=(
   kube-apiserver:v1.21.6      # k8s.gcr.io/kube-apiserver:v1.21.6
   kube-controller-manager:v1.21.6     # k8s.gcr.io/kube-controller-manager:v1.21.6
   kube-scheduler:v1.21.6      # k8s.gcr.io/kube-scheduler:v1.21.6
   kube-proxy:v1.21.6      # k8s.gcr.io/kube-proxy:v1.21.6
   pause:3.4.1     # k8s.gcr.io/pause:3.4.1
   etcd:3.4.13-0       # k8s.gcr.io/etcd:3.4.13-0
   coredns:v1.8.0      # k8s.gcr.io/coredns/coredns:v1.8.0 此镜像命名有变化
)


for imageName in ${images[@]} ; do
   echo $imageName
   docker pull registry.aliyuncs.com/google_containers/$imageName
   docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
   docker rmi registry.aliyuncs.com/google_containers/$imageName
done 
```
4. 初始化
```bash
kubeadm init --apiserver-bind-port 6443  --pod-network-cidr 192.222.0.0/16 --kubernetes-version=1.21.6
```
出现警告或异常如下:
```
[preflight] Running pre-flight checks
[WARNING FileExisting-ebtables]: ebtables not found in system path
[WARNING FileExisting-ethtool]: ethtool not found in system path
[WARNING FileExisting-socat]: socat not found in system path
error execution phase preflight: [preflight] Some fatal errors occurred:
[ERROR FileExisting-conntrack]: conntrack not found in system path
```
执行以下命令安装工具
```bash
apt install ebtables ethtool socat conntrack
```
根据初始化提示执行一下命令
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

root 用户需要执行此行
export KUBECONFIG=/etc/kubernetes/admin.conf
```
5. 添加网络插件
本次使用calico: https://docs.tigera.io/archive/v3.16/manifests/calico.yaml
> 建议提前下载calico.yaml中涉及的镜像
```bash
kubectl apply -f calico.yaml
 ```
> 本次测试使用如下文件:
> [[calico.yaml]]
### 4 work节点操作
1. 添加node节点
生成worker节点的join命令
```bash
kubeadm token create --print-join-command

创建一个永不过期的token
kubeadm token create --ttl 0 --print-join-command
```
2. 删除节点
```bash
kubectl delete node xxx
```
### 5 常用命令
1. 查看pod
```bash
kubectl get pod -A
```
2. 查看pod描述(用此命令查看容器事件)
```bash
kubectl describe pod xxx -n xxx
```
3. master节点开启pod调用
```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```
4. 控制平面节点开启pod调用
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
5. 查看命名空间
```bash
kubectl get namespaces
查看命名空间详情
kubectl describe namespace nginx
```
6. 查看deployment信息
```bash
kubectl get deployment -n xxx
``` 
7. 删除deployment
```bash
kubectl delete deployment xxx -n xxx
```
8. 查看services信息
```bash
kubectl get services -n xxx
```
9. 删除services
```bash
kubectl delete services xxx -n xxx
```
### 其他
#### kubernetes-dashboard
```bash
kubectl apply -f recommended.yaml
kubectl apply -f dashboard-adminuser.yaml

获取登录token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

打开访问代理
kubectl proxy

打开地址 http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
```
[[dashboard-adminuser.yaml]]
[[recommended.yaml]]
