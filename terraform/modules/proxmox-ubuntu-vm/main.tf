resource "proxmox_vm_qemu" "ubuntu_vm" {
  name        = var.vm_name
  target_node = var.target_node
  vmid        = var.vm_id

  clone = var.template_name

  cores  = var.cpu_cores
  memory = var.memory_mb

  agent = 1
  onboot = true

  bios   = "ovmf"
  machine = "q35"

  scsihw = "virtio-scsi-single"

  network {
    model  = "virtio"
    bridge = var.bridge
  }


  os_type = "cloud-init"
}
