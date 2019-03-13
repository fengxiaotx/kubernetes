##下载git 仓库 
位置一定要是在 /opt下
##下载可执行文件
> /opt/kubernetes/scripts/bin-download.sh

或者自己下载安装包，把执行文件移到 /opt/kubernetes/bin 下即可

##设置环境变量
> /opt/kubernetes/scripts/env.sh

##生成证书
需要修改 certs-template 下的 kubernetes-csr.json 中的hosts 中的内容，增加etcd 集群ip 以及service-cluster-ip-range 的第一个ip
> /opt/kubernetes/scripts/make-certs.sh

##配置etcd 
> /opt/kubernetes/scripts/etcd.sh etcd-name etcd-listen-ip etcd_initial_cluster 

- etcd-name : etcd的名称
- etcd-listen-ip : 本机ip
- etcd_initial_cluster : 集群信息

示例: 
> /opt/kubernetes/scripts/etcd.sh etcd-0 192.168.217.129 etcd01=https://192.168.217.129:2380

##创建 kubeconfig 文件
> /opt/kubernetes/scripts/kubeconfig.sh kube-apiserver

- kube-apiserver : apiserver的地址