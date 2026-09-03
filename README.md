# Homelab Proxmox (IaC & GitOps)

Declarative, enterprise-grade Homelab infrastructure running on Proxmox VE (Dell 5290 - 8GB RAM / 256GB SSD). Built with Infrastructure as Code (Terraform/OpenTofu) and Configuration Management (Ansible) under a strict GitOps workflow.

---

## 📐 Architecture & Key Tenets

* **Infrastructure as Code (Day 0):** Automated resource provisioning via Terraform/OpenTofu and the `bpg/proxmox` provider.
* **Configuration Management (Day 1/2):** Modular Ansible playbooks and roles for OS hardening, systemd lifecycle, and application delivery.
* **Centralized Network Control:** Single source of truth for local network resolution via AdGuard Home (DHCPv4 & Local DNS), providing zero-configuration `.lan` domain routing cluster-wide.
* **Edge Ingress & GitOps Routing:** Pure NGINX ingress router handling virtual host routing (`*.lan`) with version-controlled configuration.
* **Resource Optimization:** Unprivileged LXC containers tuned for low memory footprint, running 8+ services within 8GB RAM.

---

## 🌐 Network & Compute Matrix (Subnet: 192.168.1.0/24)

| Host / VMID | Hostname | IP Address | Services / Role | Runtime | Memory |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Physical Host** | `pve` | `192.168.1.20` | Proxmox VE Hypervisor (GUI :8006) | Bare-Metal | ~1000 MB |
| **CT 100** | `adguard` | `192.168.1.21` | AdGuard Home (Core DNS & Central DHCP Server) | LXC (Debian 12) | 128 MB |
| **CT 101** | `nginx` | `192.168.1.22` | Edge Ingress & Reverse Proxy Router | LXC (Debian 12) | 128 MB |
| **CT 102** | `Arch-server` | `192.168.1.23` | Control Plane & GitOps Automation Node | LXC (Arch Linux) | 512 MB |
| **CT 103** | `home-assistant`| `192.168.1.24` | Home Assistant Core | LXC (Debian 12) | 512 MB |
| **CT 104** | `jellyfin` | `192.168.1.25` | Jellyfin Media Server | LXC (Debian 12) | 1024 MB |
| **CT 105** | `deluge` | `192.168.1.26` | Deluge Torrent Daemon | LXC (Debian 12) | 256 MB |
| **CT 106** | `arr-stack` | `192.168.1.27` | Media Automation (Prowlarr/Radarr/Sonarr) | LXC (Debian 12) | 768 MB |
| **CT 107** | `hermes-agent` | `192.168.1.28` | Hermes AI Agent Runtime | LXC (Debian 12) | 512 MB |
| **VM 200** | `rocky-lab` | `192.168.1.29` | Enterprise Linux Sandbox (Rocky Linux) | KVM/QEMU | 2048 MB |

---

## 📂 Repository Layout

```text
Homelab-Proxmox/
├── README.md                   # System Architecture & Hardware Blueprint
├── .gitignore                  # GitOps security boundary (excludes .tfstate, *.tfvars)
├── terraform/                  # Day 0 Infrastructure Provisioning
│   ├── versions.tf             # Provider definitions (bpg/proxmox)
│   ├── variables.tf            # Input schemas & type constraints
│   ├── terraform.tfvars        # (Secret) Endpoint credentials & public keys
│   ├── .terraform.lock.hcl     # Dependency lockfile
│   ├── ct-100-adguard.tf       # CT 100 provisioner
│   └── ct-101-nginx.tf         # CT 101 provisioner
└── ansible/                    # Day 1 & Day 2 Configuration Management
    ├── ansible.cfg             # Automation defaults & SSH tuning
    ├── inventory/
    │   └── hosts.yaml          # Structured YAML host inventory
    ├── playbooks/
    │   ├── deploy-adguard.yaml # AdGuard Home deployment playbook
    │   └── deploy-nginx.yaml   # NGINX Ingress deployment playbook
    └── roles/
        ├── adguard/            # AdGuard service orchestration role
        └── nginx/              # NGINX reverse proxy & vhost templates
```

---

## 🚀 Quickstart & Provisioning Workflow

**1. Provision Compute (IaC):**

```Bash
cd terraform
terraform init
terraform apply
```

**2. Configure Nodes (Ansible):**

```Bash
cd ../ansible
ansible all -m ping
ansible-playbook playbooks/deploy-adguard.yaml
ansible-playbook playbooks/deploy-nginx.yaml
```
