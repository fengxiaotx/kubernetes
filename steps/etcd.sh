#!/usr/bin/env bash

ETCD_NAME=${1:-"etcd-1"}
ETCD_LISTEN_IP=${2:-"0.0.0.0"}
ETCD_INITIAL_CLUSTER=${3:-}

mkdir -p /opt/etcd/{bin,cfg}
wget -O /tmp/etcd-v3.3.12-linux-amd64.tar.gz -c http://ms-source.oss-cn-shanghai.aliyuncs.com/etcd/v3.3.12/etcd-v3.3.12-linux-amd64.tar.gz
tar -zvxf /tmp/etcd*.tar.gz -C /tmp/
mv /tmp/etcd*/{etcd,etcdctl} /opt/etcd/bin/

/opt/kubernetes/scripts/certs/etcd-cert.sh 

/opt/kubernetes/scripts/etcd.sh $ETCD_NAME $ETCD_LISTEN_IP $ETCD_INITIAL_CLUSTER