# NovaLab Kubernetes Platform Foundation

# Installation Guide

This document records the complete build process used to deploy the Kubernetes training cluster.

The goal is repeatability. A new engineer should be able to follow this guide and produce the same environment.

---

# Environment

Platform

- Proxmox VE
- Ubuntu Server 24.04 LTS
- Terraform
- cloud-init
- K3s

Cluster

- 1 Control Plane
- 2 Worker Nodes

---

# Deployment Workflow

1. Deploy VMs with Terraform
2. Verify cloud-init completed
3. Verify networking
4. Verify SSH access
5. Install K3s Control Plane
6. Join Worker Nodes
7. Install Helm
8. Install k9s
9. Configure KUBECONFIG
10. Install Metrics Server
11. Install cert-manager

---

# Validation Checklist

- kubectl get nodes
- kubectl get pods -A
- kubectl top nodes
- kubectl top pods -A
- helm list -A
- k9s

---

# Lessons Learned

## SSH

- Password authentication was disabled by cloud-init.
- Enabled for the lab environment.

## KUBECONFIG

- Copy /etc/rancher/k3s/k3s.yaml to ~/.kube/config
- Export KUBECONFIG
- Add export to ~/.bashrc

## Console

- Serial console works well.
- VGA provides a better interactive experience inside Proxmox.

## Helm

Successfully installed:

- cert-manager

## Metrics

Verified:

- kubectl top nodes
- kubectl top pods -A
