#!/bin/bash
#创建 TLS Bootstrapping Token
KUBE_APISERVER=${1:-"https://0.0.0.0:6443"}

BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')

#生成token.csv文件
cat > /opt/kubernetes/cfg/token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

#创建 kubelet bootstrapping kubeconfig 文件
# 设置集群参数
/opt/kubernetes/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=/opt/kubernetes/certs/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig

# 设置客户端认证参数
/opt/kubernetes/bin/kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig

# 设置上下文参数
/opt/kubernetes/bin/kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig  

# 设置默认上下文
/opt/kubernetes/bin/kubectl config use-context default --kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig

#创建 kube-proxy kubeconfig 文件
# 设置集群参数
/opt/kubernetes/bin/kubectl config set-cluster kubernetes \
  --certificate-authority=/opt/kubernetes/certs/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=/opt/kubernetes/cfg/kube-proxy.kubeconfig

# 设置客户端认证参数
/opt/kubernetes/bin/kubectl config set-credentials kube-proxy \
  --client-certificate=/opt/kubernetes/certs/kube-proxy.pem \
  --client-key=/opt/kubernetes/certs/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=/opt/kubernetes/cfg/kube-proxy.kubeconfig


# 设置上下文参数
/opt/kubernetes/bin/kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=/opt/kubernetes/cfg/kube-proxy.kubeconfig

# 设置默认上下文
/opt/kubernetes/bin/kubectl config use-context default --kubeconfig=/opt/kubernetes/cfg/kube-proxy.kubeconfig