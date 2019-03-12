#!/usr/bin/env bash
# 创建证书,根据自己的信息酌情修改certs-templete 下面的内容
#可以自己在本地创建好了，再上传到服务器上，忽略本步骤

yum install cfssl -y

CERTS_TEMPLATE_DIR=/opt/kubernetes/certs-template
CERTS_DIR=/opt/kubernetes/certs

#生成ca
cfssl gencert -initca ${CERTS_TEMPLATE_DIR}/ca-csr.json | cfssljson -bare ${CERTS_DIR}/ca

#kubernetes 
#需要修改 kubernetes-csr.json 中的etcd 集群ip 以及service-cluster-ip-range 的第一个ip
cfssl gencert -ca=${CERTS_DIR}/ca.pem -ca-key=${CERTS_DIR}/ca-key.pem -config=${CERTS_TEMPLATE_DIR}/ca-config.json -profile=kubernetes ${CERTS_TEMPLATE_DIR}/kubernetes-csr.json | cfssljson -bare ${CERTS_DIR}/kubernetes

#admin
cfssl gencert -ca=${CERTS_DIR}/ca.pem -ca-key=${CERTS_DIR}/ca-key.pem -config=${CERTS_TEMPLATE_DIR}/ca-config.json -profile=kubernetes ${CERTS_TEMPLATE_DIR}/admin-csr.json | cfssljson -bare ${CERTS_DIR}/admin

#kube-proxy
cfssl gencert -ca=${CERTS_DIR}/ca.pem -ca-key=${CERTS_DIR}/ca-key.pem -config=${CERTS_TEMPLATE_DIR}/ca-config.json -profile=kubernetes  ${CERTS_TEMPLATE_DIR}/kube-proxy-csr.json | cfssljson -bare ${CERTS_DIR}/kube-proxy