variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint URL"
  default     = "https://192.168.1.20:8006/"
}

variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API Token (Format: USER@REALM!TOKENID=SECRET)"
  sensitive   = true
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH Key to inject into containers"
}
