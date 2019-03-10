#!/usr/bin/env bash
#设置环境变量，以及关闭防火墙等准备工作
set -e

#设置环境变量
echo -e "\nexport KUBERNETES_HOME=/opt/kubernetes\nexport PATH=\${KUBERNETES_HOME}/bin:\$PATH" >> /etc/profile
source /etc/profile
echo "环境变量设置完成。。。。。"

#关闭防火墙
systemctl stop firewalld 
systemctl disable firewalld
echo "防火墙关闭完成。。。。。"

#关闭selinux
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
echo "SELINX关闭完成。。。。"

#关闭swap
swapoff -a  
sysctl -w vm.swappiness=0
sed -i 's/^UUID/#UUID/' /etc/fstab
echo "SWAP关闭完成。。。。"

#docker网桥参数
cat <<EOF >/etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/k8s.conf
echo "网桥设置完成。。。。。"