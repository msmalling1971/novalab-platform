# NovaLab Kubernetes Platform Foundation

## Overview

This project builds a reusable three-node K3s Kubernetes cluster on Proxmox VE using Terraform and cloud-init.

The objective is not simply to deploy Kubernetes, but to build a repeatable platform engineering environment that mirrors how infrastructure is deployed and managed in production.

---

## Objectives

- Build Kubernetes using Infrastructure as Code
- Standardize VM deployment with Terraform
- Automate provisioning with cloud-init
- Learn Kubernetes administration
- Build reusable platform components
- Document the complete deployment process

---

## Current Platform

- Proxmox VE
- Ubuntu Server
- Terraform
- cloud-init
- K3s
- Helm
- k9s
- Metrics Server
- cert-manager

---

## Repository Structure

terraform/ai-k3s/
├── cloud-init/
├── docs/
├── scripts/
├── README.md
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars.example

---

## Current Status

Completed

- Three-node K3s cluster
- SSH access
- Helm installed
- k9s installed
- Metrics Server deployed
- cert-manager deployed

Planned

- MetalLB
- Ingress
- Argo CD
- Prometheus
- Grafana
- Longhorn
- GitOps
