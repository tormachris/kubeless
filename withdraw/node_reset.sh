#!/bin/bash

kubeadm reset --force
docker system prune -a
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -a -q)
#iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
