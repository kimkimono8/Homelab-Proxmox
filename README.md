# Homelab Proxmox (IaC & GitOps)

Declarative, enterprise-grade Homelab infrastructure running on Proxmox VE (Dell 5290 - 8GB RAM / 256GB SSD). Built with Infrastructure as Code (Terraform/OpenTofu) and Configuration Management (Ansible) under a strict GitOps workflow.

---

## 📐 Architecture & Key Tenets

* **Infrastructure as Code (Day 0):** Automated resource provisioning via Terraform and the `bpg/proxmox` provider. Modular architecture with zero-downtime state migrations (`moved` blocks).
* **Configuration Management (Day 1/2):** Modular Ansible playbooks and roles for OS hardening, systemd lifecycle, and containerized runtime deployments.
* **Resilient Network Ingress:** Core DNS managed by AdGuard Home with internal domain resolution (`*.home`), routed through a dedicated pure NGINX ingress router.
* **Resource Optimization:** Unprivileged LXC containers meticulously tuned for micro-allocation, running 8+ services reliably within 8GB RAM.

---

## 🌐 Network & Compute Matrix (Subnet: 192.168.1.0/24)

| Host / VMID | Hostname | IP Address | Domain (`.home`) | Services / Role | Runtime | Memory |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Physical Host** | `pve` | `192.168.1.20` | - | Proxmox VE Hypervisor (GUI :8006) | Bare-Metal | ~1000 MB |
| **CT 100** | `adguard` | `192.168.1.21` | `agh.home` | AdGuard Home (Core DNS Resolver - UI :8083) | LXC (Debian 12) | 128 MB |
| **CT 101** | `nginx` | `192.168.1.22` | - | Edge Ingress & Reverse Proxy Router | LXC (Debian 12) | 128 MB |
| **CT 102** | `Arch-server`| `192.168.1.23` | - | Control Plane & GitOps Automation Node | LXC (Arch Linux) | 512 MB |
| **CT 103** | `home-assistant`| `192.168.1.24` | `hass.home` | Home Assistant Core | LXC (Debian 12) | 512 MB |
| **CT 104** | `jellyfin` | `192.168.1.25` | `jelly.home` | Jellyfin Media Server (QSV/VAAPI) | LXC (Debian 12) | 1024 MB |
| **CT 105** | `deluge` | `192.168.1.26` | `deluge.home` | Deluge Torrent Daemon | LXC (Debian 12) | 256 MB |
| **CT 106** | `arr-stack` | `192.168.1.27` | `*.home` | Media Automation (Prowlarr/Radarr/Sonarr) | LXC (Debian 12) | 768 MB |
| **CT 107** | `hermes-agent` | `192.168.1.28` | - | Hermes AI Autonomous Agent | LXC (Debian 12) | 512 MB |
| **VM 200** | `rocky-lab` | `192.168.1.29` | - | Enterprise Linux Sandbox (Rocky Linux) | KVM/QEMU | 2048 MB |

---

## 🗺️ Engineering Roadmap & Implementation Milestones

### Phase 1: Ingress Gateway & Core Control Plane (Completed)
- [x] **IaC Baseline:** Declarative Proxmox provider setup with pinned versions & remote API integration.
- [x] **Core DNS Engine:** Deploy CT 100 (`adguard` - 192.168.1.21) via Terraform & configure base role via Ansible.
- [x] **Edge Reverse Proxy:** Deploy CT 101 (`nginx` - 192.168.1.22) with lightweight templates and `.home` routing.
- [x] **Control Node & Devops Runner:** Configure CT 102 (`Arch-server` - 192.168.1.23) as the single internal automation source of truth.
- [x] **IaC Refactoring:** Modularize Terraform codebase (`modules/lxc_container`) with `for_each` data matrix and zero-downtime state migration (`moved` blocks).
- [x] **CI/CD Quality Gates:** GitHub Actions workflow with secret scanning (Gitleaks), HCL validation, and dynamic Ansible syntax checks.

### Phase 2: Home Automation & Media Backbone (In Progress)
- [x] **Home Assistant Node:** Provision CT 103 (`home-assistant` - 192.168.1.24) infrastructure via Terraform.
- [ ] **Home Assistant Provisioning:** Automated deployment via Ansible, Reverse Proxy WebSocket pass-through on NGINX, and upstream AdGuard DNS rewrite.
- [ ] **GPU-Accelerated Media Streaming:** Provision CT 104 (`jellyfin` - 192.168.1.25) with Intel QuickSync (VAAPI) passthrough configuration.
- [ ] **Centralized Storage Mounts:** Automate NFS bind mounts from Synology NAS across media & automation containers.

### Phase 3: Media Acquisition & Torrent Pipeline
- [ ] **Torrent Acquisition Node:** Provision CT 105 (`deluge` - 192.168.1.26) with automated bandwidth schedules.
- [ ] **Automation Stack:** Provision CT 106 (`arr-stack` - 192.168.1.27) consolidating Prowlarr, Radarr, and Sonarr behind unified routing.

### Phase 4: Enterprise Linux Lab & AI Runtime
- [ ] **Enterprise Testing VM:** Deploy VM 200 (`rocky-lab` - 192.168.1.29) KVM guest for RHEL sysadmin & SELinux verification.
- [ ] **AI Autonomous Agent:** Deploy CT 107 (`hermes-agent` - 192.168.1.28) runtime container.
- [ ] **Enterprise 3-2-1 Backup Strategy:** Proxmox VZDump backup jobs targeting Synology NAS with external cold storage replication.

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
│   ├── main.tf                 # Data matrix for each LXC workload
│   └── modules/
│       └── lxc_container/      # Reusable container module
└── ansible/                    # Day 1 & Day 2 Configuration Management
    ├── ansible.cfg             # Automation defaults & SSH tuning
    ├── inventory/
    │   └── hosts.yaml          # Host inventory grouped by functionality
    ├── playbooks/
    │   ├── deploy-adguard.yaml # AdGuard Home deployment playbook
    │   └── deploy-nginx.yaml   # NGINX Ingress deployment playbook
    └── roles/
        ├── adguard/            # AdGuard service orchestration role
        └── nginx/              # NGINX reverse proxy & vhost templates
```

---

## 🚀 Quickstart & Provisioning Workflow

```bash
# 1. Provision Compute Infrastructure (Terraform)
cd terraform
terraform init
terraform apply -auto-approve

# 2. Deploy Network and Application Roles (Ansible)
cd ../ansible
ansible all -i inventory/hosts.yaml -m ping
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-adguard.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-nginx.yaml
```
