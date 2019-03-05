#!/bin/bash

CLIENT=$1
IP=$2
TOKEN=$3
HASH=$4


#Installing Docker
DOCKER_INSTALLED=$(which docker)
if [ "$DOCKER_INSTALLED" = "" ]
then
	apt-get remove docker docker-engine docker.io
	apt-get update
	apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt-get update
	apt-get install -y docker-ce
fi


#Installing Kubernetes
KUBERNETES_INSTALLED=$(which kubeadm)
if [ "$KUBERNETES_INSTALLED" = "" ]
then
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	touch /etc/apt/sources.list.d/kubernetes.list
	chmod 666 /etc/apt/sources.list.d/kubernetes.list
	echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
	apt-get update
	apt-get install -y kubelet kubeadm kubectl kubernetes-cni
fi

#Disabling swap for Kubernetes
sysctl net.bridge.bridge-nf-call-iptables=1 > /dev/null
swapoff -a

if [ -z "$CLIENT" ]
then
#	kubeadm init --ignore-preflight-errors=SystemVerification
#	mkdir -p $HOME/.kube
#	cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#	chown $(id -u):$(id -g) $HOME/.kube/config
	:

elif [ "$CLIENT" = "true" ]
then
	kubeadm join $IP --token $TOKEN --discovery-token-ca-cert-hash $HASH --ignore-preflight-errors=SystemVerification
	echo "Client ($IP) joined to Master"
else
	echo "Invalid argument"
fi

