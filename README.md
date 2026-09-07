# 🏰 Homelab Proxmox (IaC & GitOps)

Declarative, enterprise-grade Homelab infrastructure running on Proxmox VE (Dell 5290 - 8GB RAM / 256GB SSD). Built with Infrastructure as Code (Terraform) and Configuration Management (Ansible) under a strict GitOps workflow.

---

## 📐 Architecture & Key Tenets

* **Declarative Core DNS:** Pi-hole v6 manages cluster-wide `.home` domains using plain `/etc/hosts` injection via Ansible `blockinfile`, eliminating stateful runtime configuration drift.
* **Storage Pipeline & Lifecycle Protection:** Container bind mounts are isolated from Terraform drift via `lifecycle.ignore_changes = [mount_point]`, while Ansible manages host mounts and enforces dependency runs automatically during media service deployments.
* **Process Priority Scheduling:** Intensive workloads (Jellyfin transcoding) utilize all available host CPU cores with high CFS time-slices (`CPUWeight=150`) and negative niceness (`Nice=-5`) without hard-locking cores.
* **Fleet-Wide Remote Management:** Unified root password configuration and OpenSSH drop-ins enable direct access via Termius/mobile without disabling key security.
* **Zero-Trust Remote Access:** Dedicated Tailscale Subnet Router (CT 108) exposes internal subnets (`192.168.1.0/24`) without opening edge firewall ports.
* **Apple-Optimized File Service:** CT 102 Samba daemon utilizes `catia`, `fruit`, and `streams_xattr` VFS modules for high-performance iOS/iPadOS Files app support.

---

## 🌐 Network & Compute Matrix (Subnet: `192.168.1.0/24`)

| Host / VMID | Hostname | Role / Service | OS | vCPU | RAM | Disk | IP Address |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| **Physical Host** | `pve` | Proxmox VE Hypervisor (GUI `:8006`) | PVE 8.x | 4 | ~1000 MB | 256 GB | `192.168.1.20` |
| **CT 100** | `pihole` | Pi-hole v6 (Core DNS & Local Domain Resolver) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.21` |
| **CT 101** | `nginx` | Edge Ingress & Reverse Proxy (`*.home`) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.22` |
| **CT 102** | `Arch-server` | Control Plane, GitOps Runner & Apple Samba Server | Arch Linux | 2 | 2048 MB | 16 GB | `192.168.1.23` |
| **CT 103** | `home-assistant` | Home Assistant Core (IoT Automation) | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.24` |
| **CT 104** | `jellyfin` | Jellyfin Media Server (Native QSV + CFS Priority) | Debian 12 | 4 | 1024 MB | 16 GB | `192.168.1.25` |
| **CT 105** | `deluge` | Deluge Torrent Daemon | Debian 12 | 1 | 256 MB | 8 GB | `192.168.1.26` |
| **CT 106** | `arr-stack` | Prowlarr + Radarr + Sonarr Automation | Debian 12 | 1 | 768 MB | 8 GB | `192.168.1.27` |
| **CT 108** | `tailscale` | Dedicated Subnet Router (`192.168.1.0/24`) & Exit Node | Debian 12 | 1 | 256 MB | 8 GB | `192.168.1.28` |
| **CT 107** | `hermes-agent` | Hermes AI Agent Runtime | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.30` |
| **VM 200** | `rocky-lab` | Enterprise Testing Sandbox (Rocky Linux) | Rocky 9 | 2 | 2048 MB | 20 GB | `192.168.1.29` |

---

## 🗺️ Engineering Roadmap & Implementation Milestones

### Phase 1: Ingress Gateway & Core Control Plane (Completed)
- [x] **IaC Baseline:** Declarative Proxmox provider setup with pinned versions & remote API integration[cite: 1].
- [x] **Core DNS & Local Resolution:** Deploy CT 100 (`pihole` - `192.168.1.21`) managing cluster-wide `.home` domains[cite: 1].
- [x] **Edge Reverse Proxy:** Deploy CT 101 (`nginx` - `192.168.1.22`) handling Layer 7 routing for internal `.home` virtual hosts[cite: 1].
- [x] **Control Plane & DevOps Runner:** Configure CT 102 (`Arch-server` - `192.168.1.23`) as the internal automation control plane[cite: 1].
- [x] **Standardized Shell Environment:** Cross-distro CLI setup (Zsh, Starship, LSD) automated via Ansible `common_shell` role[cite: 1].
- [x] **IaC Refactoring:** Modularize Terraform codebase (`modules/lxc_container`) with `for_each` data matrix and zero-downtime state migration[cite: 1].
- [x] **CI/CD Quality Gates:** GitHub Actions workflow with secret scanning (Gitleaks), HCL validation, and dynamic Ansible syntax checks[cite: 1].

### Phase 2: Hardware Acceleration, Media & Remote Gateway (Completed)
- [x] **Home Automation Node:** Provision CT 103 (`home-assistant` - `192.168.1.24`) compute resource via Terraform[cite: 1].
- [x] **Host Storage Management:** Persistent high-throughput NTFS storage automation (`/mnt/storage1`, `/mnt/storage2`) via Ansible[cite: 1].
- [x] **GPU-Accelerated Media Streaming:** Deploy CT 104 (`jellyfin` - `192.168.1.25`) with Intel QuickSync (QSV) `/dev/dri` passthrough and host-level persistent udev rules[cite: 1].
- [x] **Resource Scaling & Scheduling:** Scale CT 104 to all host CPU cores and enforce systemd scheduling overrides (`Nice=-5`, `CPUWeight=150`).
- [x] **Remote Mesh Gateway:** Provision dedicated CT 108 (`tailscale` - `192.168.1.28`) with host-level `/dev/net/tun` passthrough, serving as Subnet Router (`192.168.1.0/24`) and Exit Node[cite: 1].
- [x] **Network File Sharing:** Deploy declarative Samba server on CT 102 (`Arch-server`) sharing `/` with Apple Files app support via `vfs_fruit` and Avahi mDNS[cite: 1].

### Phase 3: Media Acquisition & Automation Pipeline (Completed)
- [x] **Torrent Acquisition Node:** Provision CT 105 (`deluge` - `192.168.1.26`) with bind-mount access to `/mnt/storage1/downloads`[cite: 1].
- [x] **Unified Routing for Deluge:** Deploy reverse proxy ingress rule `deluge.home` on CT 101[cite: 1].
- [x] **Automation Stack:** Provision CT 106 (`arr-stack` - `192.168.1.27`) consolidating Prowlarr, Radarr, and Sonarr services[cite: 1].
- [x] **Self-Healing Storage Pipeline:** Decouple mount definitions from Terraform state drift (`lifecycle.ignore_changes`) and enforce declarative auto-mount imports across media playbooks.
- [x] **Fleet-Wide Password Access:** Automate root password provisioning and OpenSSH drop-in configs (`/etc/ssh/sshd_config.d/01-permit-password.conf`) across all containers for mobile management (Termius).

### Phase 4: Enterprise Linux Lab & AI Runtime (Next Target)
- [ ] **AI Autonomous Agent:** Deploy CT 107 (`hermes-agent` - `192.168.1.30`) runtime container[cite: 1].
- [ ] **Enterprise Testing VM:** Deploy VM 200 (`rocky-lab` - `192.168.1.29`) KVM guest for RHEL sysadmin & SELinux verification[cite: 1].
- [ ] **Disaster Recovery Pipeline:** Automated Proxmox VZDump backups targeting secondary storage[cite: 1].

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
│   ├── terraform.tfvars        # (Secret) Proxmox API Credentials & root password
│   ├── containers.tf           # Reusable Module with Data Matrix
│   └── modules/lxc_container/  # Container module with lifecycle guards
└── ansible/                    # Day 1 & Day 2 Configuration Management
    ├── ansible.cfg
    ├── inventory/
    │   └── hosts.yaml          # Unified Core Infrastructure Inventory
    ├── playbooks/
    │   ├── configure-pve-gpu.yaml
    │   ├── configure-pve-storage.yaml
    │   ├── configure-tailscale-lxc.yaml
    │   ├── set-root-password.yaml
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
        ├── arr_stack/          # Prowlarr, Radarr, Sonarr stack
        ├── tailscale_node/     # Tailscale subnet router & IP forwarding
        └── samba_server/       # iOS-optimized Samba & Avahi mDNS sharing
```

---

## 🚀 Quickstart & Provisioning Workflow

### 1. Provision Compute Infrastructure (Terraform Day 0)
```bash
cd terraform
terraform init
terraform validate
terraform apply -auto-approve
```

### 2. Configure Host Devices, Storage & Access (Ansible Day 1)
```bash
cd ../ansible
# Hardware Passthrough & Host Storage
ansible-playbook -i inventory/hosts.yaml playbooks/configure-pve-gpu.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/configure-pve-storage.yaml

# Remote Password Authentication Setup
ansible-playbook -i inventory/hosts.yaml playbooks/set-root-password.yaml
```

### 3. Deploy Core Network & Ingress Services (Ansible Day 1)
```bash
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-pihole.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-nginx.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-tailscale.yaml
```

### 4. Deploy Media Acquisition, Sharing & Automation Stack (Ansible Day 2)
```bash
# Media playbooks automatically run configure-pve-storage.yaml as a prerequisite
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-jellyfin.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-deluge.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-arr.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/deploy-samba.yaml
```
