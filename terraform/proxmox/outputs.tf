output "netbox_test_vm_name" {
  value = module.netbox_test.vm_name
}

output "netbox_test_vm_id" {
  value = module.netbox_test.vm_id
}

output "environment" {
  value = var.environment
}
output "k3s_test_01_vm_name" {
  value = module.k3s_test_01.vm_name
}

output "k3s_test_01_vm_id" {
  value = module.k3s_test_01.vm_id
}