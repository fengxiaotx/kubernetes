#!/usr/bin/env bash
#可以自己根据模板修改，模板地址 https://github.com/kubernetes/kubernetes/blob/release-1.13/cluster/addons/dns/coredns/coredns.yaml.base
#__PILLAR__DNS__DOMAIN__ 和 __PILLAR__DNS__SERVER__ 酌情修改
#spec.clusterIP = 10.254.0.2，即明确指定了  Service IP，这个 IP 需要和 kubelet 的 --cluster-dns 参数值一致；

/opt/kubernetes/bin/kubectl apply -f /opt/kubernetes/yaml/coredns/coredns.yaml