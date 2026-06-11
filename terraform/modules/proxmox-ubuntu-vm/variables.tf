variable "vm_name" {
  description = "Virtual machine name"
  type        = string
}

variable "target_node" {
  description = "Proxmox node target"
  type        = string
}

variable "vm_id" {
  description = "Unique VM ID"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
}

variable "memory_mb" {
  description = "Memory allocation in MB"
  type        = number
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
}

variable "storage_name" {
  description = "Proxmox storage target"
  type        = string
}

variable "bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "template_name" {
  description = "Source VM template"
  type        = string
}

variable "environment" {
  description = "Environment label"
  type        = string
}
variable "ci_user" {
  description = "Cloud-init username"
  type        = string
}

variable "ci_password" {
  description = "Cloud-init password"
  type        = string
  sensitive   = true
}

variable "ipconfig0" {
  description = "Cloud-init network configuration for the primary network adapter"
  type        = string
  default     = "ip=dhcp"
}
