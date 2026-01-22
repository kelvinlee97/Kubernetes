#!/bin/bash

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# patch argocd's service type to become NodePort, in default is ClusterIP.
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# install argocd CLI
sudo curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x argocd
sudo mv argocd /usr/local/bin/
# check version
#argocd version --client

## ArgoCD UI ##
#https://SERVER-PUB-IP:NODEPORT/

# ArgoCD CLI login without SSL auth##
#argocd login <SERVER-PUB-IP:NODEPORT> --username <USERNAME> --password <PASSWORD> --insecure

# get argocd UI "admin" password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# argocd auto completion in bash
source <(argocd completion bash)
