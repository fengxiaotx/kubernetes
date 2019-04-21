#!/bin/bash
#创建node角色
#kubelet 启动时向 kube-apiserver 发送 TLS bootstrapping 请求，需要先将 bootstrap token 文件中的 kubelet-bootstrap 用户赋予 system:node-bootstrapper cluster 角色(role)， 然后 kubelet 才能有权限创建认证请求(certificate signing requests)：
#--user=kubelet-bootstrap 是在 /opt/kubernetes/cfg/token.csv 文件中指定的用户名，同时也写入了 /opt/kubernetes/cfg/bootstrap.kubeconfig 文件
/opt/kubernetes/bin/kubectl create clusterrolebinding kubelet-bootstrap \
  --clusterrole=system:node-bootstrapper \
  --user=kubelet-bootstrap

#kubelet 通过认证后向 kube-apiserver 发送 register node 请求，需要先将 kubelet-nodes 用户赋予 system:node cluster角色(role) 和 system:nodes 组(group)， 然后 kubelet 才能有权限创建节点请求：
/opt/kubernetes/bin/kubectl create clusterrolebinding kubelet-nodes \
  --clusterrole=system:node \
  --group=system:nodes