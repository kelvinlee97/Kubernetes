#!/bin/bash

# Test script for kubeadm-init-master.sh

# Stop on first error
set -e

# Mock log file
MOCK_LOG="/tmp/mock_commands.log"

# Mock functions
# Overwrite real commands with mocks that log the command
sudo() {
    local command_to_run="$1"
    shift
    case "$command_to_run" in
        wget|apt-get|apt|systemctl|ufw|kubeadm|cp|chown|rm|chmod|tar|mkdir|tee|sysctl|modprobe|containerd|sed|gpg|apt-mark)
            echo "sudo $command_to_run $@" >> "$MOCK_LOG"
            "$command_to_run" "$@"
            ;;
        *)
            echo "sudo $command_to_run $@" >> "$MOCK_LOG"
            ;;
    esac
}

swapoff() {
    echo "swapoff $@" >> "$MOCK_LOG"
}

tee() {
    echo "tee $@" >> "$MOCK_LOG"
}

sysctl() {
    echo "sysctl $@" >> "$MOCK_LOG"
}

modprobe() {
    echo "modprobe $@" >> "$MOCK_LOG"
}

containerd() {
    echo "containerd $@" >> "$MOCK_LOG"
    # for config default
    if [[ "$1" == "config" && "$2" == "default" ]]; then
        echo "mock containerd config"
    fi
}

sed() {
    echo "sed $@" >> "$MOCK_LOG"
}

systemctl() {
    echo "systemctl $@" >> "$MOCK_LOG"
}

export() {
    # The export command affects the current shell, so we execute it
    # to make the VERSION variable available.
    command export "$@"
}

wget() {
    echo "wget $@" >> "$MOCK_LOG"
}

tar() {
    echo "tar $@" >> "$MOCK_LOG"
}

rm() {
    echo "rm $@" >> "$MOCK_LOG"
}

chmod() {
    echo "chmod $@" >> "$MOCK_LOG"
}

curl() {
    echo "curl $@" >> "$MOCK_LOG"
}

gpg() {
    echo "gpg $@" >> "$MOCK_LOG"
}

apt-get() {
    echo "apt-get $@" >> "$MOCK_LOG"
}

apt() {
    echo "apt $@" >> "$MOCK_LOG"
}

apt-mark() {
    echo "apt-mark $@" >> "$MOCK_LOG"
}

ufw() {
    echo "ufw $@" >> "$MOCK_LOG"
}

kubeadm() {
    echo "kubeadm $@" >> "$MOCK_LOG"
}

mkdir() {
    echo "mkdir $@" >> "$MOCK_LOG"
}

cp() {
    echo "cp $@" >> "$MOCK_LOG"
}

chown() {
    echo "chown $@" >> "$MOCK_LOG"
}

kubectl() {
    echo "kubectl $@" >> "$MOCK_LOG"
}

sleep() {
    echo "sleep $@" >> "$MOCK_LOG"
}

# Source the script to be tested
# The "if" condition in the script prevents main from running on source
source ./kubeadm-init-master.sh

# Test setup
setup() {
    # Clear the mock log
    > "$MOCK_LOG"
}

# Assert function
assert_contains() {
    local pattern="$1"
    local message="$2"
    if ! grep -q "$pattern" "$MOCK_LOG"; then
        echo "FAIL: $message"
        echo "--- LOG ---"
        cat "$MOCK_LOG"
        echo "-----------"
        exit 1
    fi
    echo "PASS: $message"
}

# Test functions
test_step_1_prepare_environment() {
    setup
    step_1_prepare_environment
    assert_contains "apt-get update -y" "Step 1: apt-get update was called"
    assert_contains "swapoff -a" "Step 1: swapoff was called"
}

test_step_2_configure_networking() {
    setup
    step_2_configure_networking
    assert_contains "tee /etc/sysctl.d/k8s.conf" "Step 2: tee k8s.conf was called"
    assert_contains "sysctl --system" "Step 2: sysctl --system was called"
    assert_contains "modprobe overlay" "Step 2: modprobe overlay was called"
    assert_contains "modprobe br_netfilter" "Step 2: modprobe br_netfilter was called"
}

test_step_3_install_containerd() {
    setup
    step_3_install_containerd
    assert_contains "apt install containerd -y" "Step 3: apt install containerd was called"
    assert_contains "mkdir -p /etc/containerd" "Step 3: mkdir /etc/containerd was called"
    assert_contains "containerd config default" "Step 3: containerd config default was called"
    assert_contains "sed -i s/SystemdCgroup = false/SystemdCgroup = true/ /etc/containerd/config.toml" "Step 3: sed SystemdCgroup was called"
    assert_contains "systemctl restart containerd" "Step 3: systemctl restart containerd was called"
    assert_contains "systemctl enable containerd" "Step 3: systemctl enable containerd was called"
}

test_step_4_install_crictl() {
    setup
    step_4_install_crictl
    assert_contains "wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.35.0/crictl-v1.35.0-linux-amd64.tar.gz" "Step 4: wget crictl was called"
    assert_contains "tar zxvf crictl-v1.35.0-linux-amd64.tar.gz -C /usr/local/bin" "Step 4: tar crictl was called"
    assert_contains "rm crictl-v1.35.0-linux-amd64.tar.gz" "Step 4: rm crictl tarball was called"
    assert_contains "chmod +x /usr/local/bin/crictl" "Step 4: chmod crictl was called"
}

test_step_5_add_kube_repo() {
    setup
    step_5_add_kube_repo
    assert_contains "apt-get install -y apt-transport-https ca-certificates curl gpg" "Step 5: apt-get install dependencies was called"
    assert_contains "mkdir -p /etc/apt/keyrings" "Step 5: mkdir apt keyrings was called"
    assert_contains "gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg" "Step 5: gpg dearmor was called"
    assert_contains "tee /etc/apt/sources.list.d/kubernetes.list" "Step 5: tee kubernetes.list was called"
    assert_contains "apt-get update" "Step 5: apt-get update was called"
}

test_step_6_install_kube_binaries() {
    setup
    step_6_install_kube_binaries
    assert_contains "apt install -y kubelet kubeadm kubectl" "Step 6: apt install kube binaries was called"
    assert_contains "apt-mark hold kubelet kubeadm kubectl" "Step 6: apt-mark hold was called"
}

test_step_7_configure_firewall() {
    setup
    step_7_configure_firewall
    assert_contains "ufw allow 6443/tcp" "Step 7: ufw allow 6443 was called"
    assert_contains "ufw allow 2379:2380/tcp" "Step 7: ufw allow 2379:2380 was called"
    assert_contains "ufw allow 10250/tcp" "Step 7: ufw allow 10250 was called"
    assert_contains "ufw allow 10259/tcp" "Step 7: ufw allow 10259 was called"
    assert_contains "ufw allow 10257/tcp" "Step 7: ufw allow 10257 was called"
}

test_step_8_init_cluster() {
    setup
    step_8_init_cluster
    assert_contains "kubeadm config images pull" "Step 8: kubeadm config images pull was called"
    assert_contains "kubeadm init --pod-network-cidr=192.168.0.0/16" "Step 8: kubeadm init was called"
}

test_step_9_configure_kubectl() {
    setup
    step_9_configure_kubectl
    assert_contains "mkdir -p $HOME/.kube" "Step 9: mkdir .kube was called"
    assert_contains "cp -i /etc/kubernetes/admin.conf $HOME/.kube/config" "Step 9: cp admin.conf was called"
    assert_contains "chown $(id -u):$(id -g) $HOME/.kube/config" "Step 9: chown .kube/config was called"
}

test_step_10_install_calico() {
    setup
    step_10_install_calico
    assert_contains "kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml" "Step 10: kubectl apply calico was called"
}

test_step_11_wait_for_cluster() {
    setup
    step_11_wait_for_cluster
    assert_contains "sleep 30" "Step 11: sleep was called"
    assert_contains "kubectl get nodes" "Step 11: kubectl get nodes was called"
    assert_contains "kubectl get pods --all-namespaces" "Step 11: kubectl get pods was called"
}

test_step_12_display_join_command() {
    setup
    step_12_display_join_command
    assert_contains "kubeadm token create --print-join-command" "Step 12: kubeadm token create was called"
}

# Run all tests
run_tests() {
    test_step_1_prepare_environment
    test_step_2_configure_networking
    test_step_3_install_containerd
    test_step_4_install_crictl
    test_step_5_add_kube_repo
    test_step_6_install_kube_binaries
    test_step_7_configure_firewall
    test_step_8_init_cluster
    test_step_9_configure_kubectl
    test_step_10_install_calico
    test_step_11_wait_for_cluster
    test_step_12_display_join_command
    echo "All tests passed!"
}

run_tests
