# Proxmox VM Standard

## Purpose

Define Proxmox-specific VM standards for Terraform-managed infrastructure in NovaLab.

---

## Proxmox Defaults

| Setting | Standard |
|---|---|
| BIOS | OVMF / UEFI |
| Machine Type | q35 |
| CPU Type | host |
| SCSI Controller | virtio-scsi-single |
| Guest Agent | enabled |
| Default Bridge | vmbr0 |
| Boot Disk Bus | scsi |
| Cloud-Init | preferred |
| Template-Based Builds | preferred |

---

## Storage Standards

Default storage should be selected per environment using variables.

Examples:

- lab1: nfs-proxmox
- lab2: TBD
- local test: local-lvm

Do not hardcode storage inside reusable modules.

---

## Network Standards

Default bridge:

```text
vmbr0
