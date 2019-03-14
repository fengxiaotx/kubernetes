#!/usr/bin/env bash

MASTER_ADDRESS=${1:-"8.8.8.18"}
NODE_ADDRESS=${2:-"8.8.8.20"}
DNS_SERVER_IP=${3:-"192.168.3.100"}
DNS_DOMAIN=${4:-"cluster.local"}

CFG_DIR=/opt/kubernetes/cfg
CERTS_DIR=/opt/kubernetes/certs

# Generate a kubeconfig file
# cat <<EOF > "${KUBECONFIG_DIR}/kubelet.kubeconfig"
# apiVersion: v1
# kind: Config
# clusters:
#   - cluster:
#       server: http://${MASTER_ADDRESS}:8080/
#     name: local
# contexts:
#   - context:
#       cluster: local
#     name: local
# current-context: local
# EOF

cat <<EOF >/opt/kubernetes/cfg/kubelet
KUBE_LOGTOSTDERR="--logtostderr=true"

KUBE_LOG_LEVEL="--v=4"

NODE_ADDRESS="--address=${NODE_ADDRESS}"

NODE_PORT="--port=10250"

NODE_HOSTNAME="--hostname-override=${NODE_ADDRESS}"

KUBELET_KUBECONFIG="--kubeconfig=${CFG_DIR}/kubelet.kubeconfig"

BOOTSTRAP_KUBECONFIG="--bootstrap-kubeconfig=${CFG_DIR}/bootstrap.kubeconfig"

# --allow-privileged=false: If true, allow containers to request privileged mode. [default=false]
KUBE_ALLOW_PRIV="--allow-privileged=false"

# DNS info
KUBELET_DNS_IP="--cluster-dns=${DNS_SERVER_IP}"
KUBELET_DNS_DOMAIN="--cluster-domain=${DNS_DOMAIN}"

KUBELET_CERT_DIR="--cert-dir=${CERTS_DIR}"
KUBELET_POD_INFRA_CONTAINER_IMAGE="--pod-infra-container-image=registry.cn-shanghai.aliyuncs.com/moensun/pause-amd64:3.1"

# Add your own!
KUBELET_ARGS=""
EOF

KUBELET_OPTS="      \${KUBE_LOGTOSTDERR}     \\
                    \${KUBE_LOG_LEVEL}       \\
                    \${NODE_ADDRESS}         \\
                    \${NODE_PORT}            \\
                    \${NODE_HOSTNAME}        \\
                    \${KUBELET_KUBECONFIG}   \\
                    \${BOOTSTRAP_KUBECONFIG} \\
                    \${KUBE_ALLOW_PRIV}      \\
                    \${KUBELET_DNS_IP}       \\
                    \${KUBELET_DNS_DOMAIN}   \\
                    \${KUBELET_CERT_DIR}     \\
                    \${KUBELET_POD_INFRA_CONTAINER_IMAGE} \\
                    \$KUBELET_ARGS"

cat <<EOF >/usr/lib/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kubelet
ExecStart=/opt/kubernetes/bin/kubelet ${KUBELET_OPTS}
Restart=on-failure
KillMode=process
RestartSec=15s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
systemctl status kubelet