#!/usr/bin/env bash

MASTER_ADDRESS=${1:-"8.8.8.18"}

CERTS_DIR=/opt/kubernetes/certs

cat <<EOF >/opt/kubernetes/cfg/kube-controller-manager
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=4"
KUBE_MASTER="--master=${MASTER_ADDRESS}:8080"

KUBE_CONTROLLER_MANAGER_ROOT_CA_FILE="--root-ca-file=${CERTS_DIR}/ca.pem"

KUBE_CONTROLLER_MANAGER_SERVICE_ACCOUNT_PRIVATE_KEY_FILE="--service-account-private-key-file=${CERTS_DIR}/ca-key.pem"

KUBE_LEADER_ELECT="--leader-elect"
EOF

KUBE_CONTROLLER_MANAGER_OPTS="  \${KUBE_LOGTOSTDERR} \\
                                \${KUBE_LOG_LEVEL}   \\
                                \${KUBE_MASTER}      \\
                                \${KUBE_CONTROLLER_MANAGER_ROOT_CA_FILE} \\
                                \${KUBE_CONTROLLER_MANAGER_SERVICE_ACCOUNT_PRIVATE_KEY_FILE}\\
                                \${KUBE_LEADER_ELECT}"

cat <<EOF >/usr/lib/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-controller-manager
ExecStart=/opt/kubernetes/bin/kube-controller-manager ${KUBE_CONTROLLER_MANAGER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl restart kube-controller-manager
systemctl status kube-controller-manager