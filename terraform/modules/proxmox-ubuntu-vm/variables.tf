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
  description = "Disk size"
  type        = string
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
