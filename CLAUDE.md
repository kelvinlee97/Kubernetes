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

## CKA Exam Domains

| Domain | Weight | Key Topics |
|--------|--------|------------|
| Troubleshooting | 30% | Node/cluster debugging, logs, monitoring |
| Cluster Architecture | 25% | kubeadm, RBAC, HA control plane, Helm, CNI/CSI/CRI |
| Services & Networking | 20% | Services, NetworkPolicies, Ingress, Gateway API, CoreDNS |
| Workloads & Scheduling | 15% | Deployments, ConfigMaps/Secrets, autoscaling, node affinity |
| Storage | 10% | PV/PVC, StorageClasses, access modes, reclaim policies |
