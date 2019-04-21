#!/usr/bin/env bash

ETCD_SSL_DIR=/opt/etcd/ssl
ETCD_CFG_DIR=/opt/etcd/cfg
mkdir -p ${ETCD_SSL_DIR}
mkdir -p ${ETCD_CFG_DIR}

cat <<EOF >/opt/etcd/cfg/etcd-ca-config.json
{
    "signing": {
      "default": {
        "expiry": "87600h"
      },
      "profiles": {
        "kubernetes": {
          "expiry": "87600h",
          "usages": [
              "signing",
              "key encipherment",
              "server auth",
              "client auth"
          ]
        }
      }
    }
  }
EOF
echo "创建etcd-ca-config.json"

cat <<EOF >/opt/etcd/cfg/etcd-ca-csr.json
{
    "CN": "kubernetes",
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "JiangSu",
        "L": "SuZhou",
        "O": "k8s",
        "OU": "System"
      }
    ],
      "ca": {
         "expiry": "87600h"
      }
  }
EOF

cat <<EOF >/opt/etcd/cfg/etcd-csr.json
{
    "CN": "kubernetes",
    "hosts": [
        "172.19.182.191"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "JiangSu",
            "L": "SuZhou",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF

#生成ca
cfssl gencert -initca ${ETCD_CFG_DIR}/etcd-ca-csr.json | cfssljson -bare ${ETCD_SSL_DIR}/etcd-ca

#etcd 
cfssl gencert -ca=${ETCD_SSL_DIR}/etcd-ca.pem \
-ca-key=${ETCD_SSL_DIR}/etcd-ca-key.pem \
-config=${ETCD_CFG_DIR}/etcd-ca-config.json \
-profile=kubernetes   ${ETCD_CFG_DIR}/etcd-csr.json | cfssljson -bare ${ETCD_SSL_DIR}/etcd