#!/usr/bin/env bash
#设置环境变量，以及关闭防火墙等准备工作
set -e

#设置环境变量
echo -e "\nexport KUBERNETES_HOME=/opt/kubernetes\nexport PATH=\${KUBERNETES_HOME}/bin:\$PATH" >> /etc/profile
source /etc/profile

#关闭防火墙
systemctl stop firewalld 
systemctl disable firewalld

#关闭selinux
setenforce 0
sed -i '/^SELINUX=/SELINUX=disabled' /etc/selinux/config

#关闭swap
swapoff -a  
sysctl -w vm.swappiness=0

