#!/bin/bash

MASTER_ADDRESS=${1:-"8.8.8.18"}
ETCD_SERVERS=${2:-"https://8.8.8.18:2379"}
SERVICE_CLUSTER_IP_RANGE=${3:-"10.10.10.0/24"}
ADMISSION_CONTROL=${4:-""}

cat <<EOF >/opt/kubernetes/cfg/kube-apiserver
KUBE_LOGTOSTDERR="--logtostderr=true"

KUBE_LOG_LEVEL="--v=4"

KUBE_ETCD_SERVERS="--etcd-servers=${ETCD_SERVERS}"

KUBE_ETCD_CAFILE="--etcd-cafile=/srv/kubernetes/etcd/ca.pem"

KUBE_ETCD_CERTFILE="--etcd-certfile=/srv/kubernetes/etcd/client.pem"

KUBE_ETCD_KEYFILE="--etcd-keyfile=/srv/kubernetes/etcd/client-key.pem"

KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"

KUBE_API_PORT="--insecure-port=8080"

NODE_PORT="--kubelet-port=10250"

KUBE_ADVERTISE_ADDR="--advertise-address=${MASTER_ADDRESS}"

KUBE_ALLOW_PRIV="--allow-privileged=false"

KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE}"

KUBE_ADMISSION_CONTROL="--admission-control=${ADMISSION_CONTROL}"

KUBE_API_CLIENT_CA_FILE="--client-ca-file=/srv/kubernetes/ca.crt"

KUBE_API_TLS_CERT_FILE="--tls-cert-file=/srv/kubernetes/server.cert"

KUBE_API_TLS_PRIVATE_KEY_FILE="--tls-private-key-file=/srv/kubernetes/server.key"
EOF