#!/usr/bin/env bash

#创建 TLS Bootstrapping Token
BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')

echo "token: ${BOOTSTRAP_TOKEN}"
#生成token.csv文件
cat > /opt/kubernetes/cfg/token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF