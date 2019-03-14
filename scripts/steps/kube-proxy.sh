#!/usr/bin/env bash

MASTER_ADDRESS=${1:-"8.8.8.18"}
NODE_ADDRESS=${2:-"8.8.8.20"}
CLUSTER_CIDR=${3:-"10.254.0.0/24"}

CFG_DIR="/opt/kubernetes/cfg"

cat <<EOF >/opt/kubernetes/cfg/kube-proxy
KUBE_LOGTOSTDERR="--logtostderr=true"

KUBE_LOG_LEVEL="--v=4"

NODE_BIND_ADDRESS="--bind-address=${NODE_ADDRESS}"

NODE_HOSTNAME="--hostname-override=${NODE_ADDRESS}"

KUBE_MASTER="--master=http://${MASTER_ADDRESS}:8080"

KUBE_PROXY_OPTS="--kubeconfig=${CFG_DIR}/kube-proxy.kubeconfig --cluster-cidr=${CLUSTER_CIDR}"

EOF

KUBE_PROXY_OPTS="   \${KUBE_LOGTOSTDERR} \\
                    \${KUBE_LOG_LEVEL}   \\
                    \${NODE_BIND_ADDRESS}\\
                    \${NODE_HOSTNAME}    \\
                    \${KUBE_MASTER}      \\
                    \${KUBE_PROXY_OPTS}"

cat <<EOF >/usr/lib/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-proxy
ExecStart=/opt/kubernetes/bin/kube-proxy ${KUBE_PROXY_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-proxy
systemctl restart kube-proxy
systemctl status kube-proxy