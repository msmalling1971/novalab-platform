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

module "ubuntu_test_02" {
  source = "../modules/proxmox-ubuntu-vm"

  vm_name       = "ubuntu-test-02"
  vm_id         = 121
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
module "k3s_control_01" {
  source = "../modules/proxmox-ubuntu-vm"

  vm_name       = "k3s-control-01"
  vm_id         = 130
  target_node   = "prox1"
  template_name = "ubuntu-2404-template"

  cpu_cores    = 2
  memory_mb    = 4096
  disk_size    = 40
  storage_name = "local-lvm"
  bridge       = "vmbr0"

  ci_user     = "novaadmin"
  ci_password = "ChangeMe123!"

  ipconfig0 = "ip=192.168.50.130/24,gw=192.168.50.1"

  ssh_public_key = file("~/.ssh/id_ed25519.pub")
  environment    = var.environment
}