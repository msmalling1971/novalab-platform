module "terraform_demo_file" {
  source = "../modules/local-file-module"

  filename = "terraform-output.txt"

  content = <<EOF
Project: ${var.project_name}
Environment: ${var.environment}

This file was created through a reusable Terraform module.
EOF
}
