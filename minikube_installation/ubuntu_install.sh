#!/bin/bash

sudo apt update
sudo apt install -y curl wget apt-transport-https net-tools
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER && newgrp docker
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
minikube start --driver=docker
minikube addons enable metrics-server
minikube dashboard &
nohup kubectl proxy --address='0.0.0.0' --disable-filter=true > proxy.txt 2>&1 &
source <(kubectl completion bash)
