#!/usr/bin/env bash
#设置环境变量，以及关闭防火墙等准备工作
set -e

echo -e "\nexport ETCD_HOME=/opt/etcd\nexport PATH=\${ETCD_HOME}/bin:\$PATH" >> /etc/profile
echo -e "\nexport KUBERNETES_HOME=/opt/kubernetes\nexport PATH=\${KUBERNETES_HOME}/bin:\$PATH" >> /etc/profile
source /etc/profile
echo "环境变量设置完成。。。。。"