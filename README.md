# 1.准备工作
## 1.1.下载git 仓库 
位置一定要是在 /opt下
## 1.2.下载可执行文件
> /opt/kubernetes/scripts/steps/bin-download.sh

或者自己下载安装包，把执行文件移到 /opt/kubernetes/bin 下即可

## 1.3.设置环境变量
> /opt/kubernetes/scripts/steps/env.sh

# 2.生成证书
需要修改 certs-template 下的 kubernetes-csr.json 中的hosts 中的内容，增加etcd 集群ip 以及service-cluster-ip-range 的第一个ip
> /opt/kubernetes/scripts/steps/make-certs.sh

# 3.配置etcd 
> /opt/kubernetes/scripts/steps/etcd.sh etcd-name etcd-listen-ip etcd_initial_cluster 

- etcd-name : etcd的名称
- etcd-listen-ip : 本机ip
- etcd_initial_cluster : 集群信息

示例: 
> /opt/kubernetes/scripts/steps/etcd.sh etcd-0 192.168.217.129 etcd01=https://192.168.217.129:2380


# 4.安装master节点

## 4.1.创建kube-token
> /opt/kubernetes/scripts/steps/token.sh

## 4.2.安装 kube-apiserver
> /opt/kubernetes/scripts/steps/kube-apiserver.sh master_address etcd_servers service_cluster_ip_range enable_admission_plugins

- master_address : 本机ip
- etcd_servers : etcd集群地址
- service_cluster_ip_range : service集群的地址区间
- enable_admission_plugins : 除了默认插件之外，还需要开启的插件

示例:
> /opt/kubernetes/scripts/steps/kube-apiserver.sh 192.168.217.129 https://192.168.217.129:2379 10.254.0.0/24 NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction

## 4.3.安装 kube-scheduler
> /opt/kubernetes/scripts/steps/kube-scheduler.sh master_address

- master_address : 本机ip

示例:
> /opt/kubernetes/scripts/steps/kube-scheduler.sh 192.168.217.129

## 4.4.安装 kube-controller-manager
> /opt/kubernetes/scripts/steps/kube-controller-manager.sh master_address

- master_address : 本机地址

示例：
> /opt/kubernetes/scripts/steps/kube-controller-manager.sh 192.168.217.129

# 5.安装node节点

## 5.1.创建 flannel 网络
> /opt/kubernetes/scripts/steps/flannel.sh etcd_servers flannel_net

- etcd_servers : etcd 集群
- flannel_net : flannel 网络

示例：
> /opt/kubernetes/scripts/steps/flannel.sh https://192.168.217.129:2379 172.16.0.0/16

## 5.2.安装 docker 
> /opt/kubernetes/scripts/steps/docker.sh

这里的docker 是直接拿的可执行文件，也可以自己yum 安装，再修改配置

## 5.3.创建 kubeconfig 文件
> /opt/kubernetes/scripts/steps/kubeconfig.sh token kube-apiserver 

- token : token.sh 生成的token
- kube-apiserver : apiserver的地址
示例:
> /opt/kubernetes/scripts/steps/kubeconfig.sh 2366a641f656a0a025abb4aabda4511b https://192.168.217.129:6443

## 5.4.安装 kubelet
> /opt/kubernetes/scripts/steps/kube-kubelet.sh node_address dns_server_ip dns_domain

- node_address : 本机ip地址
- dns_server_ip : dns service 的ip (默认：10.254.0.2 )
- dns_domain: dns域名 (默认：cluster.local)

示例：
> /opt/kubernetes/scripts/steps/kube-kubelet.sh 192.168.217.129 10.254.0.2 cluster.local

## 5.5.安装 kube-proxy
> /opt/kubernetes/scripts/steps/kube-proxy.sh node_address cluster_cidr

- node_address: 本机ip
- cluster_cidr:集群中 Pod 的CIDR范围

示例：
> /opt/kubernetes/scripts/steps/kube-proxy.sh 192.168.217.129 10.254.0.0/24

# 6.dns插件安装
> /opt/kubernetes/scripts/steps/coredns.sh 

# 7.dashboard安装
> /opt/kubernetes/scripts/steps/dashboard.sh 

# 8.heapster安装

# 9.ingress-nginx 安装
> /opt/kubernetes/scripts/steps/ingress-nginx.sh 