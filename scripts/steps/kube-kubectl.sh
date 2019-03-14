#!/usr/bin/env bash

APISERVERS=${2:-"https://8.8.8.18:6443"}

CERTS_DIR=/opt/kubernetes/certs

# 设置集群参数
/opt/kubernetes/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=${CERTS_DIR}/ca.pem \
  --embed-certs=true \
  --server=${APISERVERS}


# 设置客户端认证参数
/opt/kubernetes/bin/kubectl config set-credentials admin \
  --client-certificate=${CERTS_DIR}/admin.pem \
  --embed-certs=true \
  --client-key=${CERTS_DIR}/admin-key.pem


# 设置上下文参数
/opt/kubernetes/bin/kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin


# 设置默认上下文
/opt/kubernetes/bin/kubectl config use-context kubernetes

