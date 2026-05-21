# Proxmox VM Migration Inventory

Purpose:
Track existing Proxmox VMs before migrating them one-by-one into Terraform management.

## Migration Strategy

1. Inventory current VM
2. Identify workload and risk level
3. Document CPU, RAM, disk, network, storage, IP, and dependencies
4. Rebuild or clone using Terraform
5. Validate service functionality
6. Confirm backup coverage
7. Retire manual/snowflake version
8. Repeat for next VM

## VM Inventory

| VM Name | VMID | Role | CPU | RAM | Disk | Storage | Network Bridge | IP Address | Backup Protected | Terraform Status | Notes |
|---|---:|---|---:|---:|---|---|---|---|---|---|---|
| TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD | Not Started | TBD |

| 1 | netbox | 109 | Infrastructure Source of Truth / IPAM | Ubuntu 22.04.5 LTS | 2 | 6GB | 50GB | TBD | vmbr0 | 192.168.50.221/24 | TBD | Low/Medium | Not Started | Good first Terraform migration candidate. Needs NetBox DB/config export plan before rebuild. |
