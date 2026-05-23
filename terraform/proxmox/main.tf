module "netbox_test" {
  source = "../modules/proxmox-ubuntu-vm"

  vm_name       = "netbox-test"
  vm_id         = 120
  target_node   = "prox1"
  template_name = "ubuntu-2404-template"

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size    = 40
  storage_name = "local-lvm"
  bridge       = "vmbr0"

  ci_user     = "novaadmin"
  ci_password = "ChangeMe123!"

  environment = var.environment
}
