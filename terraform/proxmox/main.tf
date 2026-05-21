resource "local_file" "terraform_test" {
  filename = "terraform-output.txt"

  content = <<EOF
Terraform is operational inside NovaLab Platform.
This file was created through Infrastructure as Code.
EOF
}
