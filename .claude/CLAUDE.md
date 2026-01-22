Dont use minikube in any environment, please use kubeadm instead.
Dont use docker in any environment, please use containerd instead.
Use Calico as CNI network plugin.
Anything please based on Kubernetes v1.35
read https://kubernetes.io/docs/home/ 

# I need to learn from these Domains & Competencies
# Storage
Implement storage classes and dynamic volume provisioning
Configure volume types, access modes and reclaim policies
Manage persistent volumes and persistent volume claims

# Troubleshooting
Troubleshoot clusters and nodes
Troubleshoot cluster components
Monitor cluster and application resource usage
Manage and evaluate container output streams
Troubleshoot services and networking

# Workloads & Scheduling
Understand application deployments and how to perform rolling update and rollbacks
Use ConfigMaps and Secrets to configure applications
Configure workload autoscaling
Understand the primitives used to create robust, self-healing, application deployments
Configure Pod admission and scheduling (limits, node affinity, etc.)

# Cluster Architecture, Installation & Configuration
Manage role based access control (RBAC)
Prepare underlying infrastructure for installing a Kubernetes cluster
Create and manage Kubernetes clusters using kubeadm
Manage the lifecycle of Kubernetes clusters
Implement and configure a highly-available control plane
Use Helm and Kustomize to install cluster components
Understand extension interfaces (CNI, CSI, CRI, etc.)
Understand CRDs, install and configure operators

# Services & Networking
Understand connectivity between Pods
Define and enforce Network Policies
Use ClusterIP, NodePort, LoadBalancer service types and endpoints
Use the Gateway API to manage Ingress traffic
Know how to use Ingress controllers and Ingress resources
Understand and use CoreDNS