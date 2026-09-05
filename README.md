# 🏰 Homelab Proxmox (IaC & GitOps)

Infrastructure as Code and GitOps orchestration repository for personal homelab running on Proxmox VE (Dell 5290 - 8GB RAM / 256GB SSD).

---

## 🌐 Network & Compute Matrix (Subnet: `192.168.1.0/24`)

| Host / VMID | Hostname | Role / Service | OS | vCPU | RAM | Disk | IP Address |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| **Physical Host** | `pve` | Proxmox VE Hypervisor (GUI `:8006`) | PVE 8.x | 4 | ~1000 MB | 256 GB | `192.168.1.20` |
| **CT 100** | `pihole` | Pi-hole v6 (Core DNS & Local Domain Resolver) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.21` |
| **CT 101** | `nginx` | Edge Ingress & Reverse Proxy (`*.home`) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.22` |
| **CT 102** | `Arch-server` | Ansible Control Node & GitOps Runner | Arch Linux | 2 | 2048 MB | 16 GB | `192.168.1.23` |
| **CT 103** | `home-assistant` | Home Assistant Core (IoT Automation) | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.24` |
| **CT 104** | `jellyfin` | Jellyfin Media Server (Native QSV Passthrough) | Debian 12 | 2 | 1024 MB | 16 GB | `192.168.1.25` |
| **CT 105** | `deluge` | Deluge Torrent Daemon | Debian 12 | 1 | 256 MB | 8 GB | `192.168.1.26` |
| **CT 106** | `arr-stack` | Prowlarr + Radarr + Sonarr Automation | Debian 12 | 1 | 768 MB | 8 GB | `192.168.1.27` |
| **CT 107** | `hermes-agent` | Hermes AI Agent Runtime | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.28` |
| **VM 200** | `rocky-lab` | Enterprise Testing Workload | Rocky 9 | 2 | 2048 MB | 20 GB | `192.168.1.29` |

---

## 🗺️ Engineering Roadmap & Implementation Milestones

This project is actively maintained and deployed in structured phases following GitOps and Infrastructure-as-Code principles.

### Phase 1: Ingress Gateway & Core Control Plane (Completed)
- [x] **IaC Baseline:** Declarative Proxmox provider setup with pinned versions & remote API integration.
- [x] **Core DNS & Local Resolution:** Deploy CT 100 (`pihole` - 192.168.1.21) headless deployment with plain `/etc/hosts` synchronization.
- [x] **Edge Reverse Proxy:** Deploy CT 101 (`nginx` - 192.168.1.22) with automated virtual hosts routing `*.home` domains.
- [x] **Control Node & GitOps Runner:** Configure CT 102 (`Arch-server` - 192.168.1.23) as the single internal automation source of truth.
- [x] **IaC Refactoring:** Modularize Terraform codebase (`modules/lxc_container`) with `for_each` data matrix and zero-downtime state migration (`moved` blocks).
- [x] **CI/CD Quality Gates:** GitHub Actions workflow with secret scanning (Gitleaks), HCL validation, and dynamic Ansible syntax checks.

### Phase 2: Hardware Acceleration & Media Backbone (Completed)
- [x] **Home Automation Node:** Provision CT 103 (`home-assistant` - 192.168.1.24) compute resource via Terraform.
- [x] **Host Storage Management:** Persistent high-throughput NTFS storage automation (`/mnt/storage1`, `/mnt/storage2`) via Ansible.
- [x] **GPU-Accelerated Media Streaming:** Deploy CT 104 (`jellyfin` - 192.168.1.25) with Intel QuickSync (QSV) `/dev/dri` passthrough and host-level persistent udev rules.
- [x] **Media Mount Points:** Persistent bind-mount integration from host `/mnt/storage2` into container `/media`.
- [x] **Standardized Shell Environment:** Cross-distro CLI setup (Zsh, Starship, LSD) automated via Ansible `common_shell` role.

### Phase 3: Media Acquisition & Automation Pipeline (In Progress)
- [ ] **Torrent Acquisition Node:** Provision CT 105 (`deluge` - 192.168.1.26) with bind-mount access to `/mnt/storage1/downloads`.
- [ ] **Unified Routing for Deluge:** Deploy reverse proxy ingress rule `deluge.home` on CT 101.
- [ ] **Automation Stack:** Provision CT 106 (`arr-stack` - 192.168.1.27) consolidating Prowlarr, Radarr, and Sonarr.

### Phase 4: Enterprise Linux Lab & AI Runtime
- [ ] **Enterprise Testing VM:** Deploy VM 200 (`rocky-lab` - 192.168.1.29) KVM guest for RHEL sysadmin & SELinux verification.
- [ ] **AI Autonomous Agent:** Deploy CT 107 (`hermes-agent` - 192.168.1.28) runtime environment.
- [ ] **Disaster Recovery Pipeline:** Automated Proxmox VZDump backups targeting secondary storage.

---

## 📐 Architecture & Key Tenets

* **Declarative Core DNS:** Pi-hole v6 manages cluster-wide `.home` domains using plain `/etc/hosts` injection via Ansible `blockinfile`, eliminating stateful runtime configuration drift.
* **Single Ingress Routing:** Edge NGINX terminates HTTP and reverse-proxies `.home` traffic to upstream application containers.
* **Shift-Left Security & CI:** GitHub Actions quality gates enforce secret leak detection, HCL validation, and Ansible syntax checks on every pull request.
* **Separation of Concerns:** Zero-downtime state separation between stateless container compute (Terraform) and system configuration (Ansible).

---

## 📂 Repository Layout

```text
Homelab-Proxmox/
├── .github/workflows/ci.yaml    # Automated CI Quality Gates (Gitleaks, Terraform, Ansible)
├── .gitignore                  # Security boundary (excludes .tfstate, *.tfvars)
├── README.md                   # System Architecture Blueprint & Roadmap
├── terraform/                  # Day 0 Compute Provisioning
│   ├── versions.tf
│   ├── variables.tf
│   ├── terraform.tfvars        # (Secret) Proxmox API Credentials
│   ├── .terraform.lock.hcl
│   ├── containers.tf           # Reusable Module with Data Matrix
│   └── modules/lxc/
└── ansible/                    # Day 1 & Day 2 Configuration Management
    ├── ansible.cfg
    ├── inventory/
    │   └── hosts.yaml          # Unified Core Infrastructure Inventory
    ├── playbooks/
    │   ├── deploy-shell.yaml
    │   ├── deploy-pihole.yaml
    │   ├── deploy-nginx.yaml
    │   ├── deploy-jellyfin.yaml
    │   └── deploy-homeassistant.yaml
    └── roles/
        ├── common_shell/       # Standardized Zsh/Starship/LSD environment
        ├── pihole/             # Pi-hole v6 unattended installer
        ├── nginx/              # Ingress routing and virtual host orchestration
        ├── jellyfin/           # Media server apt repository & systemd service
        └── homeassistant/      # Python venv Home Assistant Core
```

---

## 🚀 Quickstart Workflow

### 1. Provision Compute Infrastructure (Terraform)
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### 2. Deploy Common Developer Environment (Ansible)
```bash
cd ../ansible
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-shell.yaml
```

### 3. Deploy Platform Services
```bash
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-pihole.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-nginx.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-jellyfin.yaml
```
