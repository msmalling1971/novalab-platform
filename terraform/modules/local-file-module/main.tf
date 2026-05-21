resource "local_file" "module_file" {
  filename = var.filename
  content  = var.content
}
