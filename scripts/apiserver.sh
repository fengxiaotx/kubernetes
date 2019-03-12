#!/bin/bash

MASTER_ADDRESS=${1:-"8.8.8.18"}
ETCD_SERVERS=${2:-"https://8.8.8.18:2379"}
SERVICE_CLUSTER_IP_RANGE=${3:-"10.254.0.0/24"}
ENABLE_ADMISSION_PLUGINS=${4:-"NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction"}

CERTS_DIR=/opt/kubernetes/certs

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

KUBE_ALLOW_PRIV="--allow-privileged=true"

KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE}"

KUBE_ENABLE_ADMISSION_PLUGINS="--enable-admission-plugins=${ENABLE_ADMISSION_PLUGINS}"

KUBE_AUTHORIZATION_MODE="--authorization-mode=RBAC,Node"

KUBE_ENABLE_BOOTSTRAP_TOKEN_AUTH="--enable-bootstrap-token-auth"

KUBE_TOKEN_AUTH_FILE="--token-auth-file=/opt/kubernetes/cfg/token.csv"

KUBE_SERVICE_NODE_PORT_RANGE="--service-node-port-range=30000-50000"

KUBE_API_CLIENT_CA_FILE="--client-ca-file=${CERTS_DIR}/cp.pem"

KUBE_API_TLS_CERT_FILE="--tls-cert-file=${CERTS_DIR}/kubernetes.pem}"

KUBE_API_TLS_PRIVATE_KEY_FILE="--tls-private-key-file=${CERTS_DIR}/kubernetes-key.pem"

KUBE_SERVICE_ACCOUNT_KEY_FILE="--service-account-key-file=${CERTS_DIR}/ca-key.pem"
EOF