variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "NovaLab Platform"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "lab"
}
variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}
