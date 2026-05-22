output "vm_name" {
  value = proxmox_vm_qemu.ubuntu_vm.name
}

output "vm_id" {
  value = proxmox_vm_qemu.ubuntu_vm.vmid
}
