#!/bin/bash

# this actions will be suit on Debian OS

myaddr="10.0.1.169"
mypodcidr="10.0.2.0/24"

# init + kudeadm kubelet kubectl
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

# install containerd
sudo apt install containerd -y
sudo mkdir -p /etc/containerd/
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
# Verify SystemCgroup
# cat /etc/containerd/config.toml |grep -i SystemdCgroup
sudo systemctl restart containerd.service

# Enable IP Forwarding
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

sudo sysctl --system
sudo systemctl restart kubelet
# Verify ip forwarding
# cat /proc/sys/net/ipv4/ip_forward

sudo kubeadm init --apiserver-advertise-address $myaddr --pod-network-cidr "$mypodcidr" --upload-certs > /tmp/kubeadm_output.txt

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# install network plugin(Calico)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# kubectl auto-completion
echo 'source <(sudo kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc