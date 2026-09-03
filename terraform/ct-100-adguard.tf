resource "proxmox_virtual_environment_container" "adguard" {
  description = "AdGuard Home - Cluster DNS Resolver & Ad-blocking (Managed by Terraform)"
  node_name   = "pve"
  vm_id       = 100

  initialization {
    hostname = "adguard"

    ip_config {
      ipv4 {
        address = "192.168.1.21/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }

    dns {
      servers = ["1.1.1.1"]
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
    size         = 4 # 4 GB สำหรับ AdGuard เพียงพอใช้งานระยะยาว
  }

  operating_system {
    # ระบุ Template ที่ดาวน์โหลดไว้บน PVE Host
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
