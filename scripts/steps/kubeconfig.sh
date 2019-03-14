#!/bin/bash

BOOTSTRAP_TOKEN=${1:-}
KUBE_APISERVER=${2:-"https://0.0.0.0:6443"}

CERTS_DIR=/opt/kubernetes/certs
CFG_DIR=/opt/kubernetes/cfg
#创建 kubelet bootstrapping kubeconfig 文件
# 设置集群参数
/opt/kubernetes/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=${CERTS_DIR}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=${CFG_DIR}/bootstrap.kubeconfig

# 设置客户端认证参数
/opt/kubernetes/bin/kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=${CFG_DIR}/bootstrap.kubeconfig

# 设置上下文参数
/opt/kubernetes/bin/kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=${CFG_DIR}/bootstrap.kubeconfig  

# 设置默认上下文
/opt/kubernetes/bin/kubectl config use-context default --kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig

#创建 kube-proxy kubeconfig 文件
# 设置集群参数
/opt/kubernetes/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=${CERTS_DIR}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=${CFG_DIR}/kube-proxy.kubeconfig

# 设置客户端认证参数
/opt/kubernetes/bin/kubectl config set-credentials kube-proxy \
  --client-certificate=${CERTS_DIR}/kube-proxy.pem \
  --client-key=${CERTS_DIR}/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=${CFG_DIR}/kube-proxy.kubeconfig


# 设置上下文参数
/opt/kubernetes/bin/kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=${CFG_DIR}/kube-proxy.kubeconfig

# 设置默认上下文
/opt/kubernetes/bin/kubectl config use-context default --kubeconfig=${CFG_DIR}/kube-proxy.kubeconfig

