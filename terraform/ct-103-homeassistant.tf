resource "proxmox_virtual_environment_container" "homeassistant" {
  description  = "Home Assistant Core (Managed by Terraform)"
  node_name    = "pve"
  vm_id        = 103
  unprivileged = true

  initialization {
    hostname = "home-assistant"

    ip_config {
      ipv4 {
        address = "192.168.1.24/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }

    dns {
      servers = ["192.168.1.21", "1.1.1.1"]
    }
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 512
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  features {
    nesting = true
  }

  tags = ["automation", "iac", "iot", "terraform"]
}
