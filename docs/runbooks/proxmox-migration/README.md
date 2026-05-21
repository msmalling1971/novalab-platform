# NetBox Modernization Migration Plan

## Purpose

Migrate the existing NetBox deployment from manually managed infrastructure into reproducible Terraform-managed infrastructure.

---

# Current Architecture

## VM Information

- VM Name: netbox
- VMID: 109
- Node: prox1
- OS: Ubuntu 22.04.5 LTS
- CPU: 2
- RAM: 6GB
- Disk: 50GB
- Network: vmbr0
- IP: 192.168.50.221

---

# Current Application Stack

## NetBox

- Native Linux installation
- Installed under:
  /opt/netbox

## Python Runtime

- Python virtual environment (venv)

## Application Service

- Gunicorn
- systemd-managed service

## Database

- PostgreSQL
- Database name: netbox

## Cache / Queue

- Redis

---

# Persistence Components

## Critical Persistence

### PostgreSQL Database

Export command:

```bash
sudo -u postgres pg_dump netbox > ~/netbox-backup.sql
```

Verified backup:
- netbox-backup.sql
- Approx 1.1MB

### NetBox Configuration

Location:

```text
/opt/netbox/netbox/netbox/configuration.py
```

### Media Directory

Location:

```text
/opt/netbox/netbox/media
```

Currently minimal/empty.

---

# Modernization Goals

## Infrastructure Goals

- Terraform-managed VM lifecycle
- Standardized Ubuntu VM deployment
- Reproducible infrastructure
- Git-managed infrastructure definitions
- CI/CD validation workflows

## Application Goals

- Rebuildable NetBox deployment
- Persistent PostgreSQL protection
- Backup-aware deployment strategy
- Future observability integration

---

# Proposed Future Architecture

Terraform
↓
Proxmox VM deployment
↓
Ubuntu standardized template
↓
Docker or native NetBox deployment
↓
PostgreSQL persistence restoration
↓
Operational validation
↓
GitHub Actions validation workflows

---

# Migration Strategy

## Phase 1

- Inventory existing environment
- Validate backup/export workflows
- Build Terraform VM module
- Build standardized Ubuntu deployment

## Phase 2

- Deploy Terraform-managed replacement VM
- Install NetBox stack
- Restore PostgreSQL backup
- Restore NetBox configuration

## Phase 3

- Validate functionality
- Validate persistence
- Validate backups
- Validate networking and observability

## Phase 4

- Cut over production usage
- Retire manually managed deployment
- Maintain Terraform-managed lifecycle

---

# Operational Realizations

Modern infrastructure modernization is fundamentally:

- infrastructure reproducibility
- persistence protection
- orchestration consistency
- governance through code
- environment standardization
- operational visibility

Infrastructure can become disposable.

Persistence and orchestration state cannot.
