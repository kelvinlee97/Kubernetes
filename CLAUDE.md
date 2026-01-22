# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

CKA (Certified Kubernetes Administrator) exam study workspace.

## Technical Requirements

- Use `kubeadm` for cluster setup (not minikube)
- Use `containerd` as container runtime (not docker)
- Use **Calico** as CNI network plugin
- Target **Kubernetes v1.35** (latest stable)
- Reference: https://kubernetes.io/docs/home/

## Cluster Setup

### 1. Prepare the System

```bash
apt-get update -y
swapoff -a
```

### 2. Configure Networking

```bash
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
sudo modprobe overlay
sudo modprobe br_netfilter
```

### 3. Install containerd

```bash
sudo apt install containerd -y
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

### 4. Install Kubernetes Binaries

```bash
cd /usr/local/bin
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
sudo curl -L --remote-name-all https://dl.k8s.io/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubectl,kubelet}
sudo chmod +x kubeadm kubectl kubelet

# Install kubelet service
RELEASE_VERSION="v0.16.2"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service" | sed "s:/usr/bin:/usr/local/bin:g" | sudo tee /usr/lib/systemd/system/kubelet.service
sudo mkdir -p /usr/lib/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:/usr/local/bin:g" | sudo tee /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl daemon-reload
sudo systemctl enable --now kubelet
```

### 5. Install crictl

```bash
VERSION="v1.35.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

sudo tee /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF
```

### 6. Initialize Cluster (Control Plane)

```bash
sudo kubeadm config images pull
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

### 7. Configure kubectl

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 8. Install Calico CNI

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### 9. Join Worker Nodes

```bash
# Run on master to get join command
kubeadm token create --print-join-command
```

## Reset Cluster

```bash
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
sudo systemctl stop kubelet
```

## Quick Reference Commands

```bash
# Cluster status
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A

# Container runtime
crictl info
crictl ps
crictl images

# Troubleshooting
kubectl describe node <node>
kubectl logs <pod> -n <namespace>
journalctl -u kubelet -f

# Version checks
kubeadm version
kubectl version --client
kubelet --version
containerd --version
```

## CKA Exam Domains

| Domain | Weight | Key Topics |
|--------|--------|------------|
| Troubleshooting | 30% | Node/cluster debugging, logs, monitoring |
| Cluster Architecture | 25% | kubeadm, RBAC, HA control plane, Helm, CNI/CSI/CRI |
| Services & Networking | 20% | Services, NetworkPolicies, Ingress, Gateway API, CoreDNS |
| Workloads & Scheduling | 15% | Deployments, ConfigMaps/Secrets, autoscaling, node affinity |
| Storage | 10% | PV/PVC, StorageClasses, access modes, reclaim policies |
