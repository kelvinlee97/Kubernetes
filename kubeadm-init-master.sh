#!/bin/bash
# Kubernetes Cluster Installation Script
# Version: 1.35.0
# This script installs and configures a Kubernetes cluster using kubeadm
# on Ubuntu 20.04 LTS servers.

set -e  # Exit on error

# ============================================================================
# Step 1: Update system and prepare environment
# ============================================================================
echo "Step 1: Updating system and preparing environment..."
sudo apt-get update -y
swapoff -a

# ============================================================================
# Step 2: Configure Networking & Enable IPv4 Forwarding
# ============================================================================
echo "Step 2: Configuring networking..."
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
sudo modprobe overlay
sudo modprobe br_netfilter

# ============================================================================
# Step 3: Install and Configure containerd
# ============================================================================
echo "Step 3: Installing and configuring containerd..."
sudo apt install containerd -y
sudo mkdir -p /etc/containerd

# Generate and configure containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo sed -i 's/runtime_type = "io.containerd.runc.v1"/runtime_type = "io.containerd.runc.v2"/' /etc/containerd/config.toml

# Add CRI configuration to support RuntimeConfig
sudo tee -a /etc/containerd/config.toml <<'EOF'

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
EOF

# Start and enable containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
sleep 2

# ============================================================================
# Step 4: Install crictl
# ============================================================================
echo "Step 4: Installing crictl..."
export VERSION="v1.35.0"
CRICTL_URL="https://github.com/kubernetes-sigs/cri-tools/releases/download/\${VERSION}/crictl-\${VERSION}-linux-amd64.tar.gz"
sudo wget \${CRICTL_URL}
sudo tar zxvf crictl-\${VERSION}-linux-amd64.tar.gz -C /usr/local/bin
sudo rm crictl-\${VERSION}-linux-amd64.tar.gz
sudo chmod +x /usr/local/bin/crictl

# ============================================================================
# Step 5: Add Kubernetes Repository
# ============================================================================
echo "Step 5: Adding Kubernetes repository..."
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | \
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

# ============================================================================
# Step 6: Install Kubernetes Binaries
# ============================================================================
echo "Step 6: Installing Kubernetes binaries..."
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# ============================================================================
# Step 7: Configure Firewall and Network
# ============================================================================
echo "Step 7: Configuring firewall and network..."
# Allow Kubernetes API server port
sudo ufw allow 6443/tcp comment 'Kubernetes API server'
# Allow etcd client/server communication
sudo ufw allow 2379:2380/tcp comment 'etcd client/server'
# Allow Kubelet API
sudo ufw allow 10250/tcp comment 'Kubelet API'
# Allow kube-proxy
sudo ufw allow 10259/tcp comment 'kube-proxy'
# Allow kube-scheduler
sudo ufw allow 10257/tcp comment 'kube-scheduler'

# ============================================================================
# Step 8: Initialize the Cluster
# ============================================================================
echo "Step 8: Initializing Kubernetes cluster..."
sudo kubeadm config images pull
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# ============================================================================
# Step 9: Configure kubectl
# ============================================================================
echo "Step 9: Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ============================================================================
# Step 10: Install Calico CNI
# ============================================================================
echo "Step 10: Installing Calico CNI..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# ============================================================================
# Step 11: Wait for cluster to be ready
# ============================================================================
echo "Step 11: Waiting for cluster to be ready..."
sleep 30
kubectl get nodes
kubectl get pods --all-namespaces

# ============================================================================
# Step 12: Display Join Command (Worker nodes)
# ============================================================================
echo ""
echo "Step 12: Worker node join command:"
echo "=========================================="
sudo kubeadm token create --print-join-command
echo "=========================================="

# ============================================================================
# Worker Node Setup Instructions
# ============================================================================
echo ""
echo "For worker nodes, run the following steps:"
echo "1. Run this script on worker node (skip cluster initialization)"
echo "2. Use the join command above to join the cluster"
echo "3. Ensure worker node can reach master at 172.31.8.96:6443"

# ============================================================================
# Verification Steps (Optional - Comment out if not needed)
# ============================================================================

# Step 13: Check Cluster Status (Master node)
# kubectl cluster-info
# kubectl get nodes -o wide
# kubectl get pods -A

# Step 14: Check Container Runtime (Master node)
# sudo crictl info
# sudo crictl ps
# sudo crictl images

# Step 15: Check Versions (Master node)
# kubeadm version
# kubectl version --client
# kubelet --version
# containerd --version
# sudo crictl version

# ============================================================================
# Reset Cluster (Uncomment to use)
# ============================================================================
# sudo kubeadm reset -f
# sudo rm -rf /etc/cni/net.d
# sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
# sudo systemctl stop kubelet

# ============================================================================
# Troubleshooting Commands (Reference only)
# ============================================================================
# kubectl describe node <node>
# kubectl logs <pod> -n <namespace>
# journalctl -u kubelet -f

echo ""
echo "=========================================="
echo "Installation completed successfully!"
echo "=========================================="
