#!/usr/bin/env bash
#apiserver 安装

MASTER_ADDRESS=${1:-"8.8.8.18"}
ETCD_SERVERS=${2:-"https://8.8.8.18:2379"}
SERVICE_CLUSTER_IP_RANGE=${3:-"10.254.0.0/24"}
ENABLE_ADMISSION_PLUGINS=${4:-"NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction"}

CERTS_DIR=/opt/kubernetes/certs
CFG_DIR=/opt/kubernetes/cfg

cat <<EOF >/opt/kubernetes/cfg/kube-apiserver
KUBE_LOGTOSTDERR="--logtostderr=true"

KUBE_LOG_LEVEL="--v=4"

KUBE_ETCD_SERVERS="--etcd-servers=${ETCD_SERVERS}"

KUBE_ETCD_CAFILE="--etcd-cafile=${CERTS_DIR}/ca.pem"

KUBE_ETCD_CERTFILE="--etcd-certfile=${CERTS_DIR}/kubernetes.pem"

KUBE_ETCD_KEYFILE="--etcd-keyfile=${CERTS_DIR}/kubernetes-key.pem"

KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"

KUBE_API_PORT="--insecure-port=8080"

NODE_PORT="--kubelet-port=10250"

KUBE_ADVERTISE_ADDR="--advertise-address=${MASTER_ADDRESS}"

KUBE_ALLOW_PRIV="--allow-privileged=true"

KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=${SERVICE_CLUSTER_IP_RANGE}"

KUBE_ENABLE_ADMISSION_PLUGINS="--enable-admission-plugins=${ENABLE_ADMISSION_PLUGINS}"

KUBE_AUTHORIZATION_MODE="--authorization-mode=RBAC,Node"

KUBE_ENABLE_BOOTSTRAP_TOKEN_AUTH="--enable-bootstrap-token-auth"

KUBE_TOKEN_AUTH_FILE="--token-auth-file=${CFG_DIR}/token.csv"

KUBE_SERVICE_NODE_PORT_RANGE="--service-node-port-range=30000-50000"

KUBE_API_CLIENT_CA_FILE="--client-ca-file=${CERTS_DIR}/ca.pem"

KUBE_API_TLS_CERT_FILE="--tls-cert-file=${CERTS_DIR}/kubernetes.pem}"

KUBE_API_TLS_PRIVATE_KEY_FILE="--tls-private-key-file=${CERTS_DIR}/kubernetes-key.pem"

KUBE_SERVICE_ACCOUNT_KEY_FILE="--service-account-key-file=${CERTS_DIR}/ca-key.pem"
EOF


KUBE_APISERVER_OPTS="   \${KUBE_LOGTOSTDERR}         \\
                        \${KUBE_LOG_LEVEL}           \\
                        \${KUBE_ETCD_SERVERS}        \\
                        \${KUBE_ETCD_CAFILE}         \\
                        \${KUBE_ETCD_CERTFILE}       \\
                        \${KUBE_ETCD_KEYFILE}        \\
                        \${KUBE_API_ADDRESS}         \\
                        \${KUBE_API_PORT}            \\
                        \${NODE_PORT}                \\
                        \${KUBE_ADVERTISE_ADDR}      \\
                        \${KUBE_ALLOW_PRIV}          \\
                        \${KUBE_SERVICE_ADDRESSES}   \\
                        \${KUBE_ENABLE_ADMISSION_PLUGINS} \\
                        \${KUBE_AUTHORIZATION_MODE}  \\
                        \${KUBE_ENABLE_BOOTSTRAP_TOKEN_AUTH} \\
                        \${KUBE_TOKEN_AUTH_FILE}     \\
                        \${KUBE_SERVICE_NODE_PORT_RANGE} \\
                        \${KUBE_API_CLIENT_CA_FILE}  \\
                        \${KUBE_API_TLS_CERT_FILE}   \\
                        \${KUBE_API_TLS_PRIVATE_KEY_FILE} \\
                        \${KUBE_SERVICE_ACCOUNT_KEY_FILE}"


cat <<EOF >/usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-apiserver
ExecStart=/opt/kubernetes/bin/kube-apiserver ${KUBE_APISERVER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl restart kube-apiserver
systemctl restart kube-apiserver