#!/bin/bash

sudo yum update -y
sudo yum install -y curl wget git socat conntrack
sudo amazon-linux-extras enable docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER	
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/bin/minikube
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/bin/kubectl
#avoid minikube meet Error caching kubectl: failed to acquire lock
sudo sysctl fs.protected_regular=0
sudo minikube start --driver=docker --force
sudo chown -R $USER:$USER $HOME/.kube $HOME/.minikube
source <(sudo kubectl completion bash)
