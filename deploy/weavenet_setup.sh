#!/bin/bash

## Initialize Kubernetes
swapoff -a
kubeadm init --ignore-preflight-errors=SystemVerification
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

## Apply WeaveNet CNI plugin
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
