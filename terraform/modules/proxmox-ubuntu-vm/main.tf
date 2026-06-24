resource "proxmox_vm_qemu" "ubuntu_vm" {
  # ---------------------------------------------------------
  # VM Identity
  # Defines the VM name, target Proxmox node, and VMID.
  # ---------------------------------------------------------
  name        = var.vm_name
  target_node = var.target_node
  vmid        = var.vm_id

  # ---------------------------------------------------------
  # Clone Source
  # Creates this VM from the golden Ubuntu cloud-init template.
  # full_clone creates an independent disk copy.
  # ---------------------------------------------------------
  clone      = var.template_name
  full_clone = true

  # ---------------------------------------------------------
  # CPU / Memory
  # Basic compute sizing for the VM.
  # ---------------------------------------------------------
  cores   = var.cpu_cores
  memory  = var.memory_mb
  sockets = 1

  # ---------------------------------------------------------
  # Guest Agent / Startup
  # QEMU guest agent improves Proxmox visibility into the VM.
  # onboot starts the VM automatically with the Proxmox host.
  # ---------------------------------------------------------
  agent  = 0
  onboot = true

  # ---------------------------------------------------------
  # BIOS / Machine Type
  # OVMF enables UEFI boot.
  # q35 provides modern virtual hardware compatibility.
  # ---------------------------------------------------------
  bios    = "ovmf"
  machine = "q35"

  # ---------------------------------------------------------
  # Boot / Storage Controller
  # virtio-scsi-single matches our Ubuntu cloud image template.
  # bootdisk points Proxmox at the primary OS disk.
  # ---------------------------------------------------------
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  boot = "order=scsi0;ide2"

  # ---------------------------------------------------------
  # Disk Layout
  # Defines the primary OS disk cloned from the template.
  # Keep the disk bus aligned with the template to avoid
  # unused disk / PXE boot problems.
  # ---------------------------------------------------------
  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.disk_size
          storage = var.storage_name
        }
      }
    }
  }

  # ---------------------------------------------------------
  # Network Adapter
  # virtio provides paravirtualized network performance.
  # bridge controls which Proxmox bridge the VM connects to.
  # ---------------------------------------------------------
  network {
    model  = "virtio"
    bridge = var.bridge
  }

  # ---------------------------------------------------------
  # Cloud-Init Identity
  # Sets the default login user and password for first boot.
  # This is lab-safe for now. Later we will replace password
  # auth with SSH keys and secrets management.
  # ---------------------------------------------------------
  os_type                 = "cloud-init"
  cloudinit_cdrom_storage = var.storage_name

  ciuser     = var.ci_user
  cipassword = var.ci_password
  ipconfig0 = var.ipconfig0
  sshkeys = var.ssh_public_key
}
