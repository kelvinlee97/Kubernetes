#!/bin/bash

yum_update() {	
	sudo yum update -y > /dev/null 2>&1
	echo "yum update done~"
}
install_tools() {
	sudo yum install -y curl wget git socat conntrack > /dev/null 2>&1
	echo "install_tools done~"
}
install_docker () {
	sudo amazon-linux-extras enable docker > /dev/null 2>&1
	sudo yum install -y docker > /dev/null 2>&1
	sudo systemctl start docker > /dev/null 2>&1
	sudo systemctl enable docker > /dev/null 2>&1
	echo "install_docker and start done~"
}
docker_user() {
	sudo usermod -aG docker $USER > /dev/null 2>&1
  echo "docker_user done~"
}	
minikube() {
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 > /dev/null 2>&1
	sudo install minikube-linux-amd64 /usr/bin/minikube > /dev/null 2>&1
	echo "minikube done~"
}	
kubectl() {
	curl -LO "https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl" > /dev/null 2>&1
	sudo install kubectl /usr/bin/kubectl > /dev/null 2>&1
	echo "kubectl done~"
}
start_minikube(){
	minikube start --driver=docker --force > /dev/null 2>&1
	echo "start minikube done~"
}

chown_minikube(){
	sudo chown -R $USER:$USER $HOME/.kube $HOME/.minikube > /dev/null 2>&1
	echo "chown minikube done~"
}

#avoid minikube meet Error caching kubectl: failed to acquire lock
Disable_File_System_Protection () {
	sudo sysctl fs.protected_regular=0 > /dev/null 2>&1
 	echo "Disable_File_System_Protection done~"
}

yum_update
install_tools
install_docker
docker_user
minikube
kubectl
start_minikube
chown_minikube
Disable_File_System_Protection

exit