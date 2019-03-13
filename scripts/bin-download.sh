#!/usr/bin/env bash
#下载执行文件
set -e

KUBERNETE_BIN=/opt/kubernetes/bin

#etcd
wget -O ${KUBERNETE_BIN}/etcd -c https://ms-source.oss-cn-shanghai.aliyuncs.com/sdk/kubernetes-bin/1.13/etcd 

#etcdctl
wget -O ${KUBERNETE_BIN}/etcdctl -c https://ms-source.oss-cn-shanghai.aliyuncs.com/sdk/kubernetes-bin/1.13/etcdctl

#flanneld
wget -O ${KUBERNETE_BIN}/flanneld -c https://ms-source.oss-cn-shanghai.aliyuncs.com/sdk/kubernetes-bin/1.13/flanneld

#kubectl
wget -O ${KUBERNETE_BIN}/kubectl -c https://ms-source.oss-cn-shanghai.aliyuncs.com/sdk/kubernetes-bin/1.13/kubectl

#kube-apiserver
wget -O ${KUBERNETE_BIN}/kube-apiserver -c https://ms-source.oss-cn-shanghai.aliyuncs.com/sdk/kubernetes-bin/1.13/kube-apiserver

#kube-controller-manager
wget -O ${KUBERNETE_BIN}/kube-controller-manager -c https://ms-source.oss-cn-shanghai.aliyuncs.com/sdk/kubernetes-bin/1.13/kube-controller-manager

#kube-scheduler
wget -O ${KUBERNETE_BIN}/kube-scheduler -c https://ms-source.oss-cn-shanghai.aliyuncs.com/sdk/kubernetes-bin/1.13/kube-scheduler

#kubelet
wget -O ${KUBERNETE_BIN}/kubelet -c https://ms-source.oss-cn-shanghai.aliyuncs.com/sdk/kubernetes-bin/1.13/kubelet

#kube-proxy
wget -O ${KUBERNETE_BIN}/kube-proxy -c https://ms-source.oss-cn-shanghai.aliyuncs.com/sdk/kubernetes-bin/1.13/kube-proxy

