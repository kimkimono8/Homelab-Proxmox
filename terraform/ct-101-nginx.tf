resource "proxmox_virtual_environment_container" "nginx" {
  description = "Edge Ingress & Reverse Proxy - Pure NGINX (Managed by Terraform)"
  node_name   = "pve"
  vm_id       = 101

  initialization {
    hostname = "nginx"

    ip_config {
      ipv4 {
        address = "192.168.1.22/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }

    dns {
      servers = ["192.168.1.21", "1.1.1.1"] # ชี้ AdGuard Home (.21) เป็น Resolver หลัก
    }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 128
    swap      = 128
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  unprivileged = true

  features {
    nesting = true
  }

  started = true
}
