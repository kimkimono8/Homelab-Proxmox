# 🏰 Homelab Proxmox (IaC & GitOps)

Declarative Infrastructure as Code and GitOps orchestration repository for personal homelab running on Proxmox VE (Dell 5290 - 8GB RAM / 256GB SSD).

---

## 🌐 Network & Compute Matrix (Subnet: `192.168.1.0/24`)

| Host / VMID | Hostname | Role / Service | OS | vCPU | RAM | Disk | IP Address |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| **Physical Host** | `pve` | Proxmox VE Hypervisor (GUI `:8006`) | PVE 8.x | 4 | ~1000 MB | 256 GB | `192.168.1.20` |
| **CT 100** | `pihole` | Pi-hole v6 (Core DNS & Local Domain Resolver) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.21` |
| **CT 101** | `nginx` | Edge Ingress & Reverse Proxy (`*.home`) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.22` |
| **CT 102** | `Arch-server` | Ansible Control Node & GitOps Runner | Arch Linux | 2 | 2048 MB | 16 GB | `192.168.1.23` |
| **CT 103** | `home-assistant` | Home Assistant Core (IoT Automation) | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.24` |
| **CT 104** | `jellyfin` | Jellyfin Media Server (Intel QuickSync VAAPI) | Debian 12 | 2 | 1024 MB | 16 GB | `192.168.1.25` |
| **CT 105** | `deluge` | Deluge BitTorrent Daemon | Debian 12 | 1 | 256 MB | 8 GB | `192.168.1.26` |
| **CT 106** | `arr-stack` | Automation Stack (Prowlarr, Radarr, Sonarr, FlareSolverr) | Debian 12 | 2 | 1024 MB | 10 GB | `192.168.1.27` |
| **CT 107** | `hermes-agent` | Hermes AI Agent Runtime | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.28` |
| **VM 200** | `rocky-lab` | Enterprise Testing Workload | Rocky 9 | 2 | 2048 MB | 20 GB | `192.168.1.29` |

---

## 🗺️ Engineering Roadmap & Implementation Milestones

### Phase 1: Ingress Gateway & Core Control Plane (Completed)
- [x] **IaC Baseline:** Declarative Proxmox provider setup with pinned versions & remote API integration.
- [x] **Core DNS & Local Resolution:** Deploy CT 100 (`pihole` - `192.168.1.21`) managing cluster-wide `.home` domains.
- [x] **Edge Reverse Proxy:** Deploy CT 101 (`nginx` - `192.168.1.22`) handling Layer 7 routing for internal `.home` virtual hosts.
- [x] **Control Plane & Devops Runner:** Configure CT 102 (`Arch-server` - `192.168.1.23`) as the internal automation control plane.
- [x] **IaC Refactoring:** Modularize Terraform codebase (`modules/lxc_container`) with `for_each` data matrix and zero-downtime state migration.
- [x] **CI/CD Quality Gates:** GitHub Actions workflow with secret scanning (Gitleaks), HCL formatting/validation, and dynamic Ansible syntax checks.

### Phase 2: Home Automation & Media Backbone (Completed)
- [x] **Home Assistant Node:** Provision CT 103 (`home-assistant` - `192.168.1.24`) via Python 3.14 venv with Ingress WebSocket pass-through.
- [x] **GPU-Accelerated Media Streaming:** Provision CT 104 (`jellyfin` - `192.168.1.25`) with Intel QuickSync (VAAPI) hardware passthrough.
- [x] **Centralized NTFS Storage:** Mount high-performance external NTFS drives (`/mnt/storage1`, `/mnt/storage2`) persistently via Host `fstab`.

### Phase 3: Media Acquisition & Automation Pipeline (Completed)
- [x] **Torrent Acquisition Node:** Provision CT 105 (`deluge` - `192.168.1.26`) with declarative host storage bind mounts (`/storage1`, `/storage2`).
- [x] **Unified Routing for Deluge:** Register `deluge.home` reverse proxy route on NGINX and local DNS resolution on Pi-hole.
- [x] **Automation Stack:** Provision CT 106 (`arr-stack` - `192.168.1.27`) consolidating Prowlarr, Radarr, and Sonarr services.
- [x] **Anti-Bot Challenge Solver:** Deploy FlareSolverr headless browser proxy on CT 106 (`:8191`) for automated indexer clearance.
- [x] **Declarative Storage Bind Mounts:** Enforce full-drive persistent bind mounts (`/storage1`, `/storage2`) via Ansible host-level configuration.

### Phase 4: Enterprise Linux Lab & AI Runtime (Next Target)
- [ ] **AI Autonomous Agent:** Deploy CT 107 (`hermes-agent` - `192.168.1.28`) lightweight runtime container.
- [ ] **Enterprise Testing VM:** Deploy VM 200 (`rocky-lab` - `192.168.1.29`) KVM guest for RHEL sysadmin & SELinux verification.
- [ ] **Enterprise 3-2-1 Backup Strategy:** Proxmox VZDump backup automation with external cold replication.

---

## 📂 Repository Layout

```text
Homelab-Proxmox/
├── .github/workflows/ci.yaml    # Automated CI Quality Gates (Gitleaks, Terraform, Ansible)
├── .gitignore                  # Security boundary (excludes .tfstate, *.tfvars)
├── README.md                   # System Architecture Blueprint & Roadmap
├── terraform/                  # Day 0 Infrastructure Provisioning
│   ├── versions.tf
│   ├── variables.tf
│   ├── terraform.tfvars        # (Secret) Proxmox API Credentials
│   ├── containers.tf           # Compute Data Matrix
│   └── modules/lxc_container/  # Reusable LXC Container Module
└── ansible/                    # Day 1 & Day 2 Configuration Management
    ├── ansible.cfg
    ├── inventory/
    │   └── hosts.yaml          # Cluster Inventory
    ├── playbooks/
    │   ├── configure-pve-gpu.yaml
    │   ├── configure-pve-storage.yaml
    │   ├── deploy-pihole.yaml
    │   ├── deploy-nginx.yaml
    │   ├── deploy-homeassistant.yaml
    │   ├── deploy-jellyfin.yaml
    │   ├── deploy-deluge.yaml
    │   └── deploy-arr.yaml
    └── roles/
        ├── pihole/
        ├── nginx/
        ├── homeassistant/
        ├── jellyfin/
        ├── deluge/
        └── arr_stack/
```

---

## 🚀 Quickstart & Provisioning Workflow

### 1. Provision Compute Infrastructure (Terraform):
```bash
cd terraform
terraform init
terraform validate
terraform apply -auto-approve
```

### 2. Configure Host Devices & Persistent Storage (Ansible):
```bash
cd ../ansible
ansible-playbook -i inventory/hosts.yaml playbooks/configure-pve-gpu.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/configure-pve-storage.yaml
```

### 3. Deploy Core Network & Ingress Services (Ansible):
```bash
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-pihole.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-nginx.yaml
```

### 4. Deploy Media Acquisition & Automation Stack (Ansible):
```bash
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-deluge.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-arr.yaml
```
