# Terraform Proxmox Modernization

## Executive Summary

The Terraform Proxmox modernization project establishes a repeatable infrastructure pattern for NovaLab virtual machines on Proxmox. The work moves lab infrastructure away from manually built, one-off VMs and toward Git-managed infrastructure definitions, reusable Terraform modules, standardized Ubuntu templates, and cloud-init based first boot configuration.

This project is intentionally both practical and educational. It captures the engineering transition from manually operating infrastructure to treating infrastructure as a governed platform: reusable, reviewable, documented, and capable of being reconciled back to a known desired state.

The current implementation includes a reusable Proxmox Ubuntu VM module, a root Proxmox Terraform configuration, Ubuntu 24.04 template standardization, UEFI/OVMF and q35 virtual hardware standards, cloud-init integration, and Terraform-managed deployments for VM120 and VM121.

## Project Goals

- Build a reusable Terraform module for Ubuntu VM deployments on Proxmox.
- Standardize new VM builds around Ubuntu Server 24.04 LTS.
- Use a golden cloud-init capable template as the source for repeatable clones.
- Standardize Proxmox VM hardware settings, including OVMF/UEFI, q35, virtio networking, and SCSI boot disks.
- Keep environment-specific values configurable rather than hardcoded inside reusable modules.
- Manage infrastructure lifecycle through Git-backed Terraform code.
- Learn and document Terraform reconciliation behavior, including provider drift and state alignment.
- Support gradual modernization of existing workloads instead of risky big-bang migrations.

## Architecture Overview

The current architecture uses a root Terraform configuration under `terraform/proxmox` and a reusable VM module under `terraform/modules/proxmox-ubuntu-vm`.

The root configuration defines concrete VM instances. At the time of this document, it uses the module to manage:

- `netbox-test`, VMID `120`
- `ubuntu-test-02`, VMID `121`

Both VMs are cloned from the `ubuntu-2404-template` Proxmox template and deployed to the `prox1` node using `local-lvm` storage and the `vmbr0` network bridge.

The module encapsulates the standard VM shape:

- Proxmox QEMU VM resource
- Full clone from a golden template
- Variable-driven CPU, memory, disk, storage, bridge, VM name, VMID, and target node
- OVMF/UEFI firmware
- q35 machine type
- SCSI boot disk
- virtio network adapter
- cloud-init username and password inputs

The target model is simple by design:

```text
Git repository
  -> Terraform root configuration
  -> Reusable Proxmox Ubuntu VM module
  -> Proxmox API
  -> Template-based Ubuntu VM
  -> cloud-init first boot configuration
```

## Technologies Used

- Terraform `>= 1.5.0`
- Telmate Proxmox Terraform provider `3.0.1-rc1`
- Proxmox VE
- Proxmox QEMU virtual machines
- Ubuntu Server 24.04 LTS
- cloud-init
- OVMF/UEFI firmware
- q35 virtual machine type
- virtio networking
- SCSI-based virtual disk layout
- Git-based infrastructure management

## Implementation Details

### Terraform Module Design

The project uses a reusable module named `proxmox-ubuntu-vm`. The module accepts VM identity, placement, sizing, storage, networking, template, cloud-init, and environment inputs. This keeps the module generic enough for multiple lab workloads while still enforcing common VM standards.

Key module inputs include:

- `vm_name`
- `vm_id`
- `target_node`
- `template_name`
- `cpu_cores`
- `memory_mb`
- `disk_size`
- `storage_name`
- `bridge`
- `ci_user`
- `ci_password`
- `environment`

The root configuration is responsible for declaring actual VM instances. This keeps workload-specific decisions near the environment definition while the module owns the repeatable VM construction pattern.

### Template Standardization

The standardized build pattern depends on a golden Ubuntu 24.04 template named `ubuntu-2404-template`. Instead of repeatedly installing Ubuntu by hand, Terraform clones from the template and applies VM-specific configuration.

This matters because the template becomes the infrastructure baseline. Firmware, disk expectations, cloud-init compatibility, guest behavior, and boot assumptions all need to align before Terraform can reliably create and reconcile VMs.

The repository standards define Ubuntu Server 24.04 LTS as the preferred base OS and cloud-init capable templates as the preferred deployment pattern for Terraform-managed infrastructure.

### Proxmox VM Standards

The project standardizes modern VM settings for Terraform-managed Proxmox workloads:

- BIOS: OVMF / UEFI
- Machine type: q35
- CPU type: host
- Default bridge: vmbr0
- Boot disk bus: scsi
- Template-based builds preferred
- Cloud-init preferred

The module currently configures OVMF, q35, a SCSI boot disk, virtio networking, and cloud-init settings. The standards documentation also calls out guest agent enablement and virtio SCSI alignment as desired defaults for the platform.

### Cloud-Init Integration

Cloud-init is used to configure first boot identity for cloned Ubuntu VMs. The module sets:

- `os_type = "cloud-init"`
- cloud-init CD-ROM storage
- cloud-init username
- cloud-init password

This allows Terraform-created VMs to boot from a shared template while still receiving per-VM access configuration. In the current lab implementation, password-based access is used as a transitional pattern. The module comments correctly identify SSH keys and secrets management as future improvements.

### Terraform as a Reconciliation Engine

One of the most important lessons from this project is that Terraform is not just a deployment script.

A deployment script usually runs a set of steps once. If something already exists, changed manually, partially failed, or drifted afterward, the script may not know the real current state.

Terraform works differently. Terraform compares three things:

- The desired state written in code
- The last known state recorded in Terraform state
- The real infrastructure state reported by the provider

From that comparison, Terraform builds a plan to reconcile the infrastructure toward the desired configuration. This is why state management matters. It is also why provider behavior matters. If the Proxmox provider reports values differently than they were declared, Terraform may detect drift even when the VM appears healthy in the Proxmox UI.

In this project, investigating provider drift and reconciliation behavior became part of the engineering work. The practical takeaway is that Terraform code is only one part of the system. The provider, state file, template design, and platform defaults all participate in the reconciliation loop.

### VM120 and VM121 Validation Journey

VM120 was the first Terraform-managed VM created through this Proxmox modernization effort. It was more than a test machine. It became the validation platform for the reusable module, the Ubuntu 24.04 template, and the Terraform workflow itself.

VM120 exposed several issues that had to be understood and corrected before the pattern could be trusted:

- EFI disk alignment
- Boot order assumptions
- Cloud-init configuration
- Guest-agent behavior
- Provider drift
- Template alignment

Those issues were valuable because they showed where automation depends on standards. The goal was not simply to create a VM. The goal was to create a repeatable process for creating VMs, where the module, template, provider, and Proxmox defaults all worked together consistently.

After VM120 helped validate the pattern, VM121 was deployed from the same module with minimal additional effort. That second deployment mattered because it demonstrated repeatability. VM121 proved that the work was not a one-off success tied to a single VM, but a reusable infrastructure pattern that could be applied again.

## Challenges Encountered

### Provider Drift and State Alignment

The project exposed the difference between creating a VM and maintaining a VM through Terraform over time. Provider-reported values can differ from the values written in configuration, especially around Proxmox virtual hardware details. Those differences can produce unexpected plans.

The lesson is to read Terraform plans as reconciliation proposals, not just deployment previews. A plan is telling the operator how Terraform interprets the relationship between code, state, and the provider's view of reality.

### Template and Disk Alignment

Template-based VM creation depends on consistent assumptions between the template and the Terraform module. Disk bus, boot order, firmware, and machine type need to line up. If they do not, a VM can clone successfully but boot incorrectly or expose unused disk behavior.

The module comments explicitly call out the need to keep the disk bus aligned with the template to avoid unused disk and PXE boot problems.

### Manual Infrastructure History

Existing lab services were not born inside Terraform. For example, the NetBox migration notes document a manually managed Ubuntu 22.04.5 VM with PostgreSQL, Redis, Gunicorn, systemd services, and application files under `/opt/netbox`.

That kind of workload cannot be responsibly "Terraformed" by only creating a replacement VM. Persistence, configuration, backup validation, service restoration, and cutover planning all matter.

### Security and Secret Handling

The current module accepts a cloud-init password as a sensitive Terraform variable, but the root lab configuration still uses a placeholder password value. That is acceptable as a learning-stage lab pattern, but it is not the final platform target.

Future iterations should replace password bootstrap with SSH keys and improve secret handling.

## Lessons Learned

- Terraform is strongest when treated as a reconciliation engine with state, not as a procedural deployment script.
- Standardized templates reduce deployment variance, but only if the template and Terraform module agree on firmware, machine type, disk layout, and cloud-init behavior.
- Reusable modules should encode common platform decisions while leaving environment-specific details configurable.
- Git-based infrastructure management improves reviewability and repeatability, but it also requires disciplined state handling.
- Existing workloads need migration plans, not just replacement infrastructure.
- Persistence and orchestration state deserve more protection than the VM shell around them.
- Gradual modernization creates room for validation, learning, and rollback.

## Modernization Strategy

The modernization approach for NovaLab is intentionally gradual.

A big-bang migration would attempt to move many workloads into Terraform at once. That can look efficient on paper, but it creates unnecessary operational risk. Existing systems often have undocumented dependencies, persistent data, manual configuration, and implicit operational knowledge. Moving everything at once makes it harder to isolate failures and harder to learn from each step.

The preferred strategy is one workload at a time:

1. Inventory the existing VM.
2. Identify workload role, dependencies, persistence, and risk.
3. Validate export and backup procedures.
4. Deploy a standardized Terraform-managed replacement VM.
5. Restore or rebuild the application layer.
6. Validate service behavior, networking, persistence, and backups.
7. Cut over usage when confidence is high.
8. Retire the manual version only after validation.

This approach is already reflected in the Proxmox migration runbook. The NetBox migration plan starts with inventory and backup validation before replacement. That sequence is the right platform engineering instinct: make the rebuild path real before treating infrastructure as disposable.

## Matt's Notes

### What Surprised Me

Terraform cared about infrastructure differences I did not even know existed.

Before this project, I understood VMs mostly from the operational side: CPU, memory, disk, network, OS, and service availability. Terraform forced me to look at the lower-level details that make automation reliable: firmware mode, machine type, disk bus, boot order, cloud-init attachment, guest-agent behavior, provider state, and template assumptions.

### What Broke

- EFI disk alignment
- Cloud-init configuration
- Guest-agent behavior
- Boot order assumptions
- Provider drift

### What I Learned

The template is more important than the VM.

Standardization must come before automation.

Terraform is a reconciliation engine rather than a deployment script.

The technical work was not only "make Terraform create a VM." The more valuable work was learning where repeatability actually comes from: template discipline, provider behavior, state management, module boundaries, and clear operational documentation.

### What I Would Do Differently

I would establish standards before attempting large-scale automation.

I would create the golden image first.

I would document lessons learned earlier in the process.

### What I'm Exploring Next

- SSH key injection
- Static IP assignment
- Windows 11 templates
- Windows Server 2025 templates
- Environment separation
- GitHub Actions
- Observability integration

## Evidence and Validation

Success for this project was validated through both Terraform workflow checks and platform-level VM behavior.

Validation included:

- `terraform plan`
- `terraform apply`
- `terraform state list`
- Proxmox VM creation
- Successful Ubuntu boot
- Cloud-init user creation
- Reusable deployment of VM121 from the same module pattern

The important validation point was not only that VM120 existed. The stronger signal was that VM121 could be created from the same module with minimal additional work. That showed the project had moved from a single successful deployment toward a repeatable operating pattern.

Screenshots, diagrams, and architecture visuals will be added as the project evolves.

## Why This Matters

For hiring managers and technical leadership, this project demonstrates more than home lab experimentation. It shows infrastructure modernization thinking applied in a real, constrained environment.

The work demonstrates infrastructure modernization by moving from manually built systems toward standardized, Git-managed infrastructure. It demonstrates platform engineering thinking by focusing on reusable patterns, documented standards, operational validation, and gradual adoption rather than one-off automation.

It also shows a practical Terraform adoption strategy. Terraform was introduced first around a controlled VM pattern, then validated through repeatable deployments, state awareness, provider behavior, and documented lessons learned. That is the kind of adoption path that can scale responsibly because it builds trust before expanding scope.

The gradual migration methodology is especially important. Existing workloads often carry operational history, persistence concerns, and undocumented assumptions. This project treats modernization as a sequence of validated steps: inventory, standardize, automate, reconcile, validate, then migrate. That approach reduces risk while still moving the platform forward.

## Future Roadmap

- Replace password-based cloud-init bootstrap with SSH key injection.
- Improve secret handling for Proxmox credentials and guest initialization.
- Align module defaults fully with documented Proxmox standards, including guest agent behavior and SCSI controller expectations.
- Add Terraform validation through GitHub Actions.
- Expand environment-specific tfvars usage for multiple lab environments.
- Add clearer state management documentation and recovery procedures.
- Continue one-by-one migration planning for existing Proxmox VMs.
- Build a NetBox migration implementation after backup, restore, and cutover procedures are validated.
- Add observability standards for Terraform-managed VMs.
- Integrate inventory management, potentially through NetBox, once the infrastructure model is stable.
