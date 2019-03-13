#!/usr/bin/env bash

ETCD_SERVERS=${1:-"http://8.8.8.18:4001"}
FLANNEL_NET=${2:-"172.16.0.0/16"}

CERTS_DIR=/opt/kubernetes/certs
CA_FILE="${CERTS_DIR}/ca.pem"
CERT_FILE="${CERTS_DIR}/kubernetes.pem"
KEY_FILE="${CERTS_DIR}/kubernetes-key.pem"

cat <<EOF >/opt/kubernetes/cfg/flannel
FLANNEL_ETCD="-etcd-endpoints=${ETCD_SERVERS}"
FLANNEL_ETCD_KEY="-etcd-prefix=/moensun.com/network"
FLANNEL_ETCD_CAFILE="--etcd-cafile=${CA_FILE}"
FLANNEL_ETCD_CERTFILE="--etcd-certfile=${CERT_FILE}"
FLANNEL_ETCD_KEYFILE="--etcd-keyfile=${KEY_FILE}"
EOF

cat <<EOF >/usr/lib/systemd/system/flannel.service
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
Before=docker.service

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/flannel
ExecStartPre=/opt/kubernetes/bin/remove-docker0.sh
ExecStart=/opt/kubernetes/bin/flanneld --ip-masq \${FLANNEL_ETCD} \${FLANNEL_ETCD_KEY} \${FLANNEL_ETCD_CAFILE} \${FLANNEL_ETCD_CERTFILE} \${FLANNEL_ETCD_KEYFILE}
ExecStartPost=/opt/kubernetes/bin/mk-docker-opts.sh -d /run/flannel/docker

Type=notify

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF

# Store FLANNEL_NET to etcd.
attempt=0
while true; do
  /opt/kubernetes/bin/etcdctl --ca-file ${CA_FILE} --cert-file ${CERT_FILE} --key-file ${KEY_FILE} \
    --no-sync -C ${ETCD_SERVERS} \
    get /moensun.com/network/config >/dev/null 2>&1
  if [[ "$?" == 0 ]]; then
    break
  else
    if (( attempt > 600 )); then
      echo "timeout for waiting network config" > ~/kube/err.log
      exit 2
    fi

    /opt/kubernetes/bin/etcdctl --ca-file ${CA_FILE} --cert-file ${CERT_FILE} --key-file ${KEY_FILE} \
      --no-sync -C ${ETCD_SERVERS} \
      mk /moensun.com/network/config "{\"Network\":\"${FLANNEL_NET}\",\"SubnetLen\":24,\"Backend\":{\"Type\":\"vxlan\"}}" >/dev/null 2>&1
    attempt=$((attempt+1))
    sleep 3
  fi
done
wait

systemctl enable flannel
systemctl daemon-reload
systemctl restart flannel
systemctl status flannel