#!/bin/bash

## Initialize Kubernetes
kubeadm init --ignore-preflight-errors=SystemVerification
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

## Apply Cilium CNI plugin
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.4/examples/kubernetes/1.13/cilium.yaml
