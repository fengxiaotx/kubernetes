#!/bin/bash

etcd_data_dir=/var/lib/etcd
mkdir -p ${etcd_data_dir}

ETCD_NAME=${1:-"etcd-1"}
ETCD_LISTEN_IP=${2:-"0.0.0.0"}
ETCD_INITIAL_CLUSTER=${3:-}


CERTS_DIR=/opt/etcd/ssl

cat <<EOF >/opt/etcd/cfg/etcd.conf
#[Member]
ETCD_NAME="${ETCD_NAME}"
ETCD_DATA_DIR="${etcd_data_dir}/default.etcd"
ETCD_LISTEN_PEER_URLS="https://${ETCD_LISTEN_IP}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${ETCD_LISTEN_IP}:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ETCD_LISTEN_IP}:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_LISTEN_IP}:2379"

#[Clustering]
ETCD_INITIAL_CLUSTER="${ETCD_INITIAL_CLUSTER}"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_CERT_FILE="${CERTS_DIR}/etcd.pem"
ETCD_KEY_FILE="${CERTS_DIR}/etcd-key.pem"
ETCD_PEER_CERT_FILE="${CERTS_DIR}/etcd.pem"
ETCD_PEER_KEY_FILE="${CERTS_DIR}/etcd-key.pem"
ETCD_TRUSTED_CA_FILE="${CERTS_DIR}/etcd-ca.pem"
ETCD_PEER_TRUSTED_CA_FILE="${CERTS_DIR}/etcd-ca.pem"
EOF


cat <<EOF >/usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=-/opt/etcd/cfg/etcd.conf
ExecStart=/opt/etcd/bin/etcd \\
--name=\${ETCD_NAME} \\
--data-dir=\${ETCD_DATA_DIR} \\
--listen-peer-urls=\${ETCD_LISTEN_PEER_URLS} \\
--listen-client-urls=\${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \\
--advertise-client-urls=\${ETCD_ADVERTISE_CLIENT_URLS} \\
--initial-advertise-peer-urls=\${ETCD_INITIAL_ADVERTISE_PEER_URLS} \\
--initial-cluster=\${ETCD_INITIAL_CLUSTER} \\
--initial-cluster-token=\${ETCD_INITIAL_CLUSTER_TOKEN} \\
--initial-cluster-state=new \\
--cert-file=\${ETCD_CERT_FILE} \\
--key-file=\${ETCD_KEY_FILE} \\
--peer-cert-file=\${ETCD_PEER_CERT_FILE} \\
--peer-key-file=\${ETCD_PEER_KEY_FILE} \\
--trusted-ca-file=\${ETCD_TRUSTED_CA_FILE} \\
--peer-trusted-ca-file=\${ETCD_PEER_TRUSTED_CA_FILE}
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
systemctl status etcd