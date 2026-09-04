locals {
  containers = {
    adguard = {
      vm_id       = 100
      hostname    = "adguard"
      description = "Core DNS & Central DHCP Server"
      ip_address  = "192.168.1.21/24"
      cores       = 1
      memory      = 128
      swap        = 128
      disk_size   = 8
      tags        = ["dns", "dhcp", "network", "iac"]
    }
    nginx = {
      vm_id       = 101
      hostname    = "nginx"
      description = "Edge Ingress & Reverse Proxy Router"
      ip_address  = "192.168.1.22/24"
      cores       = 1
      memory      = 128
      swap        = 128
      disk_size   = 8
      tags        = ["ingress", "proxy", "network", "iac"]
    }
    homeassistant = {
      vm_id        = 103
      hostname     = "home-assistant"
      description  = "Home Assistant Core (Python venv)"
      ip_address   = "192.168.1.24/24"
      cores        = 2
      memory       = 512
      swap         = 512
      disk_size    = 8
      unprivileged = true  # กลับมาใช้ Unprivileged มาตรฐาน
      keyctl       = false # ไม่ต้องใช้ keyctl
      tags         = ["automation", "iot", "iac"]
    }
  }
}

module "containers" {
  source   = "./modules/lxc_container"
  for_each = local.containers

  vm_id          = each.value.vm_id
  hostname       = each.value.hostname
  description    = each.value.description
  ip_address     = each.value.ip_address
  cores          = each.value.cores
  memory         = each.value.memory
  swap           = each.value.swap
  disk_size      = each.value.disk_size
  tags           = each.value.tags
  ssh_public_key = var.ssh_public_key

  unprivileged = lookup(each.value, "unprivileged", true)
  keyctl       = lookup(each.value, "keyctl", false)
}
