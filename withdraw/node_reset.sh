#!/bin/bash

kubeadm reset --force
iptables -F && iptables -t nat -F && iptables -t mangle -F && \
iptables -X && iptables -t nat -X && iptables -t mangle -X
service docker restart
