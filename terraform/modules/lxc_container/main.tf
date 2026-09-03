resource "proxmox_virtual_environment_container" "this" {
  description  = var.description
  node_name    = var.node_name
  vm_id        = var.vm_id
  unprivileged = true

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }

    dns {
      servers = var.dns_servers
    }
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = "debian"
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  features {
    nesting = true
  }

  tags = var.tags
}
