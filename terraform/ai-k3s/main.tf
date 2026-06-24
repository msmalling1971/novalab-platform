module "k3s_control_01" {
  source = "../modules/proxmox-ubuntu-vm"

  vm_name       = "k3s-control-01"
  vm_id         = 300
  target_node   = "prox1-ark-core"
  template_name = "ubuntu-2404-template"

  cpu_cores = 4
  memory_mb = 8192

  disk_size    = "80"
  storage_name = "local-lvm"

  bridge    = "vmbr0"
  ipconfig0 = "ip=192.168.50.80/24,gw=192.168.50.1"

  ci_user     = "novaadmin"
  ci_password = "ChangeMe123!"

  ssh_public_key = file("/home/msmalling/.ssh/id_ed25519.pub")

  environment = "ai-k3s"
}