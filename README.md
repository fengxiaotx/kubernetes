# 1.准备工作
## 1.1下载git 仓库 
位置一定要是在 /opt下
## 1.2下载可执行文件
> /opt/kubernetes/scripts/steps/bin-download.sh

或者自己下载安装包，把执行文件移到 /opt/kubernetes/bin 下即可

## 1.3设置环境变量
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

## 4.1创建kube-token
> /opt/kubernetes/scripts/steps/token.sh

## 4.2安装 kube-apiserver
> /opt/kubernetes/scripts/steps/kube-apiserver.sh master_address etcd_servers service_cluster_ip_range enable_admission_plugins

- master_address : 本机ip
- etcd_servers : etcd集群地址
- service_cluster_ip_range : service集群的地址区间
- enable_admission_plugins : 除了默认插件之外，还需要开启的插件

示例:
> /opt/kubernetes/scripts/steps/kube-apiserver.sh 192.168.217.129 https://192.168.217.129:2379 10.254.0.0/24 NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction

## 4.3安装 kube-scheduler
> /opt/kubernetes/scripts/steps/kube-scheduler.sh master_address

- master_address : 本机ip

示例:
> /opt/kubernetes/scripts/steps/kube-scheduler.sh 192.168.217.129

## 创建 kubeconfig 文件
> /opt/kubernetes/scripts/steps/kubeconfig.sh kube-apiserver

- kube-apiserver : apiserver的地址
示例:
> /opt/kubernetes/scripts/steps/etcd.sh 