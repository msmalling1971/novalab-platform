output "generated_file" {
  description = "The Terraform-managed output file"

  value = module.terraform_demo_file.created_filename
}

output "environment" {
  description = "The active deployment environment"

  value = var.environment
}
