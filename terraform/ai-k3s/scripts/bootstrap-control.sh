#!/bin/bash

set -e

echo "======================================"
echo " NovaLab K3s Control Bootstrap"
echo "======================================"

echo
echo "Updating packages..."
sudo apt update
sudo apt upgrade -y

echo
echo "Installing utilities..."
sudo apt install -y \
    curl \
    wget \
    git \
    jq \
    unzip \
    vim

echo
echo "Installing Helm..."

if ! command -v helm >/dev/null 2>&1; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo
echo "Installing k9s..."

if ! command -v k9s >/dev/null 2>&1; then
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r .tag_name)
    curl -Lo k9s.tar.gz https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
    tar -xzf k9s.tar.gz
    sudo mv k9s /usr/local/bin/
    rm -f k9s.tar.gz LICENSE README.md
fi

echo
echo "Configuring kubectl..."

mkdir -p ~/.kube

sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

if ! grep -q KUBECONFIG ~/.bashrc; then
    echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
fi

echo
echo "Bootstrap complete."
echo
echo "Run:"
echo
echo "source ~/.bashrc"
echo "kubectl get nodes"
echo "helm version"
echo "k9s"
