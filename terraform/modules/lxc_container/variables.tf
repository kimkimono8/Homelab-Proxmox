variable "node_name" {
  type        = string
  description = "Target Proxmox node"
  default     = "pve"
}

variable "vm_id" {
  type        = number
  description = "LXC VM ID"
}

variable "hostname" {
  type        = string
  description = "Container hostname"
}

variable "description" {
  type        = string
  description = "Resource description"
  default     = "Managed by Terraform"
}

variable "ip_address" {
  type        = string
  description = "Static IPv4 CIDR (e.g., 192.168.1.20/24)"
}

variable "gateway" {
  type        = string
  description = "Default IPv4 Gateway"
  default     = "192.168.1.1"
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS Nameservers"
  default     = ["192.168.1.21", "1.1.1.1"]
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for root access"
}

variable "template_file_id" {
  type        = string
  description = "Proxmox OS template storage ID"
  default     = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
}

variable "cores" {
  type        = number
  description = "CPU core count"
  default     = 1
}

variable "memory" {
  type        = number
  description = "Dedicated RAM (MB)"
  default     = 128
}

variable "swap" {
  type        = number
  description = "Swap memory (MB)"
  default     = 128
}

variable "disk_size" {
  type        = number
  description = "Disk volume size in GB"
  default     = 8
}

variable "datastore_id" {
  type        = string
  description = "Storage datastore"
  default     = "local-lvm"
}

variable "tags" {
  type        = list(string)
  description = "Resource tags"
  default     = ["iac", "terraform"]
}
variable "unprivileged" {
  type        = bool
  description = "Whether the container is unprivileged"
  default     = true
}

variable "keyctl" {
  type        = bool
  description = "Enable keyctl feature"
  default     = false
}
