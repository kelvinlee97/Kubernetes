#!/bin/bash

# system up to date
sudo yum update -y

# install some common tools
sudo yum install -y curl wget git socat conntrack

# install docker
sudo amazon-linux-extras enable docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# configure to docker user
sudo usermod -aG docker $USER

# download && install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/bin/minikube

# download && install kubectl
curl -LO "https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl"
sudo install kubectl /usr/bin/kubectl

# start minikube
minikube start --driver=docker --force

# Configure Permissions for kubectl
sudo chown -R $USER:$USER $HOME/.kube $HOME/.minikube

exit
