#!/bin/bash

# this actions will be suit on Debian OS(Ubuntu)

# regular update and install tools need
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# install kubelet kubeadm kubectl with v1.32 version
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

# install containerd
sudo apt install containerd -y
sudo mkdir -p /etc/containerd/
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd.service

# Enable IP Forwarding and iptable bridge
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
sudo modprobe br_netfilter

# kubectl auto-completion
echo 'source <(kubectl completion bash)' >> ~/.bashrc
/bin/bash -c 'source ~/.bashrc'
