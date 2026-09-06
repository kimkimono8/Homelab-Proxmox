# 🏰 Homelab Proxmox (IaC & GitOps)

Declarative, enterprise-grade Homelab infrastructure running on Proxmox VE (Dell 5290 - 8GB RAM / 256GB SSD). Built with Infrastructure as Code (Terraform) and Configuration Management (Ansible) under a strict GitOps workflow.

---

## 📐 Architecture & Key Tenets

* **Declarative Core DNS:** Pi-hole v6 manages cluster-wide `.home` domains using plain `/etc/hosts` injection via Ansible `blockinfile`, eliminating stateful runtime configuration drift.
* **Zero-Trust Remote Access:** Dedicated Tailscale Subnet Router (CT 108) exposes the internal subnet (`192.168.1.0/24`) to remote clients without port forwarding.
* **Apple-Optimized File Service:** CT 102 Samba daemon utilizes `catia`, `fruit`, and `streams_xattr` VFS modules for compatibility with iOS/iPadOS Files app.
* **Single Ingress Routing:** Edge NGINX terminates HTTP and reverse-proxies `.home` traffic to upstream application containers.
* **Separation of Concerns:** Zero-downtime state separation between stateless container compute (Terraform) and system configuration (Ansible).

---

## 🌐 Network & Compute Matrix (Subnet: `192.168.1.0/24`)

| Host / VMID | Hostname | Role / Service | OS | vCPU | RAM | Disk | IP Address |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| **Physical Host** | `pve` | Proxmox VE Hypervisor (GUI `:8006`) | PVE 8.x | 4 | ~1000 MB | 256 GB | `192.168.1.20` |
| **CT 100** | `pihole` | Pi-hole v6 (Core DNS & Local Domain Resolver) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.21` |
| **CT 101** | `nginx` | Edge Ingress & Reverse Proxy (`*.home`) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.22` |
| **CT 102** | `Arch-server` | Control Plane, GitOps Runner & Apple Samba Server | Arch Linux | 2 | 2048 MB | 16 GB | `192.168.1.23` |
| **CT 103** | `home-assistant` | Home Assistant Core (IoT Automation) | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.24` |
| **CT 104** | `jellyfin` | Jellyfin Media Server (Native QSV Passthrough) | Debian 12 | 2 | 1024 MB | 16 GB | `192.168.1.25` |
| **CT 105** | `deluge` | Deluge Torrent Daemon | Debian 12 | 1 | 256 MB | 8 GB | `192.168.1.26` |
| **CT 106** | `arr-stack` | Automation Stack (Prowlarr, Radarr, Sonarr, FlareSolverr) | Debian 12 | 2 | 1024 MB | 10 GB | `192.168.1.27` |
| **CT 108** | `tailscale` | Dedicated Subnet Router (`192.168.1.0/24`) & Exit Node | Debian 12 | 1 | 256 MB | 8 GB | `192.168.1.28` |
| **CT 107** | `hermes-agent` | Hermes AI Agent Runtime | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.30` |
| **VM 200** | `rocky-lab` | Enterprise Testing Workload (Rocky Linux) | Rocky 9 | 2 | 2048 MB | 20 GB | `192.168.1.29` |

---

## 🗺️ Engineering Roadmap & Implementation Milestones

This project is actively maintained and deployed in structured phases following GitOps and Infrastructure-as-Code principles.

### Phase 1: Ingress Gateway & Core Control Plane (Completed)
- [x] **IaC Baseline:** Declarative Proxmox provider setup with pinned versions & remote API integration [cite: 1, 4].
- [x] **Core DNS & Local Resolution:** Deploy CT 100 (`pihole` - `192.168.1.21`) managing cluster-wide `.home` domains [cite: 2, 4].
- [x] **Edge Reverse Proxy:** Deploy CT 101 (`nginx` - `192.168.1.22`) handling Layer 7 routing for internal `.home` virtual hosts [cite: 2, 4].
- [x] **Control Plane & DevOps Runner:** Configure CT 102 (`Arch-server` - `192.168.1.23`) as the internal automation control plane [cite: 2, 4].
- [x] **Standardized Shell Environment:** Cross-distro CLI setup (Zsh, Starship, LSD) automated via Ansible `common_shell` role [cite: 4].
- [x] **IaC Refactoring:** Modularize Terraform codebase (`modules/lxc_container`) with `for_each` data matrix and zero-downtime state migration [cite: 2, 4].
- [x] **CI/CD Quality Gates:** GitHub Actions workflow with secret scanning (Gitleaks), HCL formatting/validation, and dynamic Ansible syntax checks [cite: 1, 4].

### Phase 2: Hardware Acceleration, Media & Remote Gateway (Completed)
- [x] **Home Automation Node:** Provision CT 103 (`home-assistant` - `192.168.1.24`) via Python 3.14 venv with Ingress WebSocket pass-through [cite: 2, 4].
- [x] **Host Storage Management:** Persistent high-throughput NTFS storage automation (`/mnt/storage1`, `/mnt/storage2`) via Ansible [cite: 4].
- [x] **GPU-Accelerated Media Streaming:** Deploy CT 104 (`jellyfin` - `192.168.1.25`) with Intel QuickSync (QSV) `/dev/dri` passthrough and host-level persistent udev rules [cite: 4].
- [x] **Media Mount Points:** Persistent bind-mount integration from host `/mnt/storage2` into container `/media` [cite: 4].
- [x] **Remote Mesh Gateway:** Provision dedicated CT 108 (`tailscale` - `192.168.1.28`) with host-level `/dev/net/tun` passthrough, serving as Subnet Router (`192.168.1.0/24`) and Exit Node [cite: 2].
- [x] **Network File Sharing:** Deploy declarative Samba server on CT 102 (`Arch-server`) sharing `/` with Apple Files app support via `vfs_fruit` and Avahi mDNS [cite: 2].

### Phase 3: Media Acquisition & Automation Pipeline (Completed)
- [x] **Torrent Acquisition Node:** Provision CT 105 (`deluge` - `192.168.1.26`) with declarative host storage bind mounts (`/storage1`, `/storage2`) [cite: 2, 4].
- [x] **Unified Routing for Deluge:** Register `deluge.home` reverse proxy route on NGINX and local DNS resolution on Pi-hole [cite: 4].
- [x] **Automation Stack:** Provision CT 106 (`arr-stack` - `192.168.1.27`) consolidating Prowlarr, Radarr, and Sonarr services [cite: 2, 4].
- [x] **Anti-Bot Challenge Solver:** Deploy FlareSolverr headless browser proxy on CT 106 (`:8191`) for automated indexer clearance [cite: 2, 4].
- [x] **Declarative Storage Bind Mounts:** Enforce full-drive persistent bind mounts (`/storage1`, `/storage2`) via Ansible host-level configuration [cite: 2, 4].

### Phase 4: Enterprise Linux Lab & AI Runtime (In Progress)
- [ ] **AI Autonomous Agent:** Deploy CT 107 (`hermes-agent` - `192.168.1.30`) runtime container.
- [ ] **Enterprise Testing VM:** Deploy VM 200 (`rocky-lab` - `192.168.1.29`) KVM guest for RHEL sysadmin & SELinux verification [cite: 2, 4].
- [ ] **Enterprise 3-2-1 Backup Strategy:** Proxmox VZDump backup automation with external cold replication [cite: 2, 4].

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
│   ├── .terraform.lock.hcl
│   ├── containers.tf           # Compute Data Matrix
│   └── modules/lxc_container/  # Reusable LXC Container Module
└── ansible/                    # Day 1 & Day 2 Configuration Management
    ├── ansible.cfg
    ├── inventory/
    │   └── hosts.yaml          # Cluster Inventory
    ├── playbooks/
    │   ├── configure-pve-gpu.yaml
    │   ├── configure-pve-storage.yaml
    │   ├── configure-tailscale-lxc.yaml
    │   ├── deploy-shell.yaml
    │   ├── deploy-pihole.yaml
    │   ├── deploy-nginx.yaml
    │   ├── deploy-homeassistant.yaml
    │   ├── deploy-jellyfin.yaml
    │   ├── deploy-deluge.yaml
    │   ├── deploy-arr.yaml
    │   ├── deploy-tailscale.yaml
    │   └── deploy-samba.yaml
    └── roles/
        ├── common_shell/       # Standardized Zsh/Starship/LSD environment
        ├── pihole/             # Pi-hole v6 unattended installer
        ├── nginx/              # Ingress routing and virtual host orchestration
        ├── homeassistant/      # Python venv Home Assistant Core
        ├── jellyfin/           # Media server apt repository & systemd service
        ├── deluge/             # BitTorrent daemon and web UI
        ├── arr_stack/          # Prowlarr, Radarr, Sonarr, FlareSolverr stack
        ├── tailscale_node/     # Tailscale subnet router & IP forwarding
        └── samba_server/       # iOS-optimized Samba & Avahi mDNS sharing
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

### 2. Configure Host Devices, Persistent Storage & Tuning (Ansible):
```bash
cd ../ansible
ansible-playbook -i inventory/hosts.yaml playbooks/configure-pve-gpu.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/configure-pve-storage.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/configure-tailscale-lxc.yaml
```

### 3. Deploy Platform & Core Network Infrastructure (Ansible):
```bash
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-shell.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-pihole.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-nginx.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-tailscale.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-samba.yaml
```

### 4. Deploy Media Applications & IoT Automation (Ansible):
```bash
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-homeassistant.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-jellyfin.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-deluge.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-arr.yaml
```
