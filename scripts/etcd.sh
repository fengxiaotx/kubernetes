#!/bin/bash

etcd_data_dir=/var/lib/etcd
mkdir -p ${etcd_data_dir}

ETCD_NAME=${1:-"etcd-default"}
ETCD_LISTEN_IP=${2:-"0.0.0.0"}
ETCD_INITIAL_CLUSTER=${3:-}
CERTS_DIR=/opt/kubernetes/certs

cat <<EOF >/opt/kubernetes/cfg/etcd.conf
# [member]
ETCD_NAME="--name=${ETCD_NAME}"
ETCD_DATA_DIR="--data-dir=${etcd_data_dir}/default.etcd"
#ETCD_SNAPSHOT_COUNTER="10000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
ETCD_LISTEN_PEER_URLS="--listen-peer-urls=https://${ETCD_LISTEN_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="--listen-client-urls=https://${ETCD_LISTEN_IP}:2379,https://127.0.0.1:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="--initial-advertise-peer-urls=https://${ETCD_LISTEN_IP}:2380"
# if you use different ETCD_NAME (e.g. test),
# set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="--initial-cluster=${ETCD_INITIAL_CLUSTER}"
ETCD_INITIAL_CLUSTER_STATE="--initial-cluster-state=new"
ETCD_INITIAL_CLUSTER_TOKEN="--initial-cluster-token=k8s-etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="--advertise-client-urls=https://${ETCD_LISTEN_IP}:2379"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_SRV=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#
#[proxy]
#ETCD_PROXY="off"
#
#[security]
CLIENT_CERT_AUTH="true"
ETCD_CA_FILE="--trusted-ca-file=${CERTS_DIR}/ca.pem"
ETCD_CERT_FILE="--cert-file=${CERTS_DIR}/kubernetes.pem"
ETCD_KEY_FILE="--key-file=${CERTS_DIR}/kubernetes-key.pem"
PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_CA_FILE="--peer-trusted-ca-file=${CERTS_DIR}/ca.pem"
ETCD_PEER_CERT_FILE="--peer-cert-file=${CERTS_DIR}/kubernetes.pem"
ETCD_PEER_KEY_FILE="--peer-key-file=${CERTS_DIR}/kubernetes-key.pem"
EOF

ETCD_OPS="  \${ETCD_NAME}                         \\
            \${ETCD_DATA_DIR}                     \\
            \${ETCD_LISTEN_PEER_URLS}             \\
            \${ETCD_LISTEN_CLIENT_URLS}           \\
            \${ETCD_INITIAL_ADVERTISE_PEER_URLS}  \\
            \${ETCD_INITIAL_CLUSTER}              \\
            \${ETCD_INITIAL_CLUSTER_STATE}        \\
            \${ETCD_INITIAL_CLUSTER_TOKEN}        \\
            \${ETCD_ADVERTISE_CLIENT_URLS}        \\
            \${ETCD_CA_FILE}                      \\
            \${ETCD_CERT_FILE}                    \\
            \${ETCD_KEY_FILE}                     \\
            \${ETCD_PEER_CA_FILE}                 \\
            \${ETCD_PEER_KEY_FILE}"

cat <<EOF >/usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
[Service]
Type=simple
WorkingDirectory=${etcd_data_dir}
EnvironmentFile=-/opt/kubernetes/cfg/etcd.conf
# set GOMAXPROCS to number of processors
ExecStart=/bin/bash -c "GOMAXPROCS=\$(nproc) /opt/kubernetes/bin/etcd ${ETCD_OPS}"
Type=notify
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
systemctl status etcd