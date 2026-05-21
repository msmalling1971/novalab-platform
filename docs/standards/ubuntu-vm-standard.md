# Ubuntu VM Standard

## Purpose

Define standardized Ubuntu VM deployment patterns for Terraform-managed infrastructure.

---

# Base Standards

## OS

- Ubuntu Server 24.04 LTS preferred
- cloud-init capable template

---

# Virtual Hardware Standards

## BIOS

- OVMF (UEFI)

## Machine Type

- q35

## SCSI Controller

- virtio-scsi-single

## CPU Type

- host

## QEMU Agent

- enabled

---

# Default VM Categories

## Utility VM

Purpose:
- lightweight infrastructure tooling
- DNS
- jump hosts
- small services

Suggested Resources:
- 2 vCPU
- 4GB RAM
- 40GB disk

---

## Docker Host

Purpose:
- Compose stacks
- monitoring
- web applications
- AI tooling

Suggested Resources:
- 4 vCPU
- 8GB RAM
- 100GB disk

---

## Monitoring Node

Purpose:
- Grafana
- Prometheus
- Loki
- observability stacks

Suggested Resources:
- 4 vCPU
- 8GB RAM
- larger persistent storage

---

# Network Standards

- vmbr0 default bridge
- DHCP allowed for lab
- static IPs preferred for critical infrastructure

---

# Operational Standards

## Backup Protection

All persistent workloads must:
- have backup validation
- support export/recovery
- document persistence locations

## Terraform Governance

All Terraform-managed infrastructure should:
- use reusable modules
- avoid hardcoded values
- support variable-driven environments
- maintain Git-managed lifecycle

---

# Future Goals

- reusable Terraform VM modules
- GitHub Actions Terraform validation
- environment-specific tfvars
- NetBox inventory integration
- observability standardization
- DR-aware rebuild workflows# Ubuntu VM Standard

## Purpose

Define standardized Ubuntu VM deployment patterns for Terraform-managed infrastructure.

---

# Base Standards

## OS

- Ubuntu Server 24.04 LTS preferred
- cloud-init capable template

---

# Virtual Hardware Standards

## BIOS

- OVMF (UEFI)

## Machine Type

- q35

## SCSI Controller

- virtio-scsi-single

## CPU Type

- host

## QEMU Agent

- enabled

---

# Default VM Categories

## Utility VM

Purpose:
- lightweight infrastructure tooling
- DNS
- jump hosts
- small services

Suggested Resources:
- 2 vCPU
- 4GB RAM
- 40GB disk

---

## Docker Host

Purpose:
- Compose stacks
- monitoring
- web applications
- AI tooling

Suggested Resources:
- 4 vCPU
- 8GB RAM
- 100GB disk

---

## Monitoring Node

Purpose:
- Grafana
- Prometheus
- Loki
- observability stacks

Suggested Resources:
- 4 vCPU
- 8GB RAM
- larger persistent storage

---

# Network Standards

- vmbr0 default bridge
- DHCP allowed for lab
- static IPs preferred for critical infrastructure

---

# Operational Standards

## Backup Protection

All persistent workloads must:
- have backup validation
- support export/recovery
- document persistence locations

## Terraform Governance

All Terraform-managed infrastructure should:
- use reusable modules
- avoid hardcoded values
- support variable-driven environments
- maintain Git-managed lifecycle

---

# Future Goals

- reusable Terraform VM modules
- GitHub Actions Terraform validation
- environment-specific tfvars
- NetBox inventory integration
- observability standardization
- DR-aware rebuild workflows
