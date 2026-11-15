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
