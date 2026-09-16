Warning: Identity file /root/.ssh/id_rsa not accessible: No such file or directory.
# 🏰 Homelab Proxmox (IaC & GitOps)

Declarative, enterprise-grade Homelab infrastructure running on Proxmox VE (MSI PRO H610M-E — i3-12100 / 8GB DDR4 / 250GB NVMe + 3× 1TB HDD / 750W PSU). Built with Infrastructure as Code (Terraform) and Configuration Management (Ansible) under a strict GitOps workflow.

---

## 📐 Architecture & Key Tenets

* **Declarative Core DNS:** Pi-hole v6 manages cluster-wide `.home` domains using plain `/etc/hosts` injection via Ansible `blockinfile`, eliminating stateful runtime configuration drift[cite: 13].
* **Host Power & Thermal Management:** Enforces `powersave` governor via native systemd oneshot service on Debian 13/PVE 9 with `thermald` daemon integration to mitigate thermal buildup on laptop server hardware.
* **Storage Pipeline & Lifecycle Protection:** Container bind mounts are isolated from Terraform drift via `lifecycle.ignore_changes = [mount_point]`, while Ansible manages host mounts and enforces dependency runs automatically during media service deployments[cite: 13].
* **Process Priority Scheduling:** Intensive workloads (Jellyfin transcoding) utilize all available host CPU cores with high CFS time-slices (`CPUWeight=150`) and negative niceness (`Nice=-5`) without hard-locking cores[cite: 13].
* **Fleet-Wide Remote Management:** Unified root password configuration and OpenSSH drop-ins enable direct access via Termius/mobile without disabling key security[cite: 13].
* **Zero-Trust Remote Access:** Dedicated Tailscale Subnet Router (CT 108) exposes internal subnets (`192.168.1.0/24`) without opening edge firewall ports[cite: 12, 13].
* **Apple-Optimized File Service:** CT 102 Samba daemon utilizes `catia`, `fruit`, and `streams_xattr` VFS modules for high-performance iOS/iPadOS Files app support[cite: 12, 13].

---

## 🖥️ Host Hardware Specification

```
CPU      : Intel Core i3-12100 (12th Gen, 4C/8T, max 4.3 GHz)
RAM      : 8 GB DDR4-2400 MHz (1×8 GB, single-channel, 1.2 V)
SSD      : Samsung SSD 970 EVO Plus 250 GB NVMe (system + LVM pve-root/pve-data)
HDD      : 1 TB ×3 (ST1000LM024 ×2, WDC WD10SPZX ×1) → /mnt/backup, /mnt/hdd2, /mnt/hdd3
MB       : MSI PRO H610M-E DDR4 (MS-7D48, rev 2.0)
PSU      : 750W 80+ Bronze
NIC      : Realtek RTL8111/8168/8211/8411 PCI-E Gigabit (eth0)
GPU      : Intel UHD Graphics 730 (Alder Lake-S GT1, onboard)
BIOS     : A.M0 — 08/05/2025
OS       : Proxmox VE 9.x (Debian 13 trixie, kernel 7.0.14-17-pve)
```

### Mounted Storage

| Mount       | Device  | Model                        | Size   | Used   |
|-------------|---------|------------------------------|--------|--------|
| `/`         | nvme0n1 | Samsung SSD 970 EVO Plus 250G| 67 GB  | 5.7G   |
| swap        | nvme0n1 + zram0 | —                  | 11 GB  | 157M   |
| `/mnt/backup`| sda1   | ST1000LM024 HN-M101MBB       | 931.5G | 143G   |
| `/mnt/hdd2` | sdb1    | WDC WD10SPZX-08Z10           | 931.5G | 2.1M   |
| `/mnt/hdd3` | sdc1    | ST1000LM024 HN-M101MBB       | 931.5G | 2.1M   |
| `/mnt/usb1` | sdd1    | WDC WD10JMVW-11AJGS2         | 931.5G | —      |
| `/mnt/usb2` | sde1    | WDC WD10JMVW-11AJGS2         | 931.5G | —      |

### LXC / VM Disk Allocation (LVM `pve-data`, 137.5G pool)

| CT/VM | Hostname        | Disk |
|-------|-----------------|------|
| 100   | pihole          | 4G   |
| 101   | nginx           | 8G   |
| 102   | Arch-server     | 8G   |
| 103   | home-assistant  | 8G   |
| 104   | jellyfin        | 16G  |
| 105   | deluge          | 8G   |
| 106   | arr-stack       | 10G  |
| 107   | hermes-agent    | 8G   |
| 108   | tailscale       | 8G   |

---

## 🌐 Network & Compute Matrix (Subnet: `192.168.1.0/24`)

| Host / VMID | Hostname | Role / Service | OS | vCPU | RAM | Disk | IP Address |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| **Physical Host** | `pve` | Proxmox VE Hypervisor (GUI `:8006`) | Debian 13 (trixie) / PVE 9.x | 8 | ~3.1 GB | 250 GB NVMe + 3× 1TB HDD | `192.168.1.20` |
| **CT 100** | `pihole` | Pi-hole v6 (Core DNS & Local Domain Resolver) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.21` |
| **CT 101** | `nginx` | Edge Ingress & Reverse Proxy (`*.home`) | Debian 12 | 1 | 128 MB | 4 GB | `192.168.1.22` |
| **CT 102** | `Arch-server` | Control Plane, GitOps Runner & Apple Samba Server | Arch Linux | 2 | 2048 MB | 16 GB | `192.168.1.23` |
| **CT 103** | `home-assistant` | Home Assistant Core (IoT Automation) | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.24` |
| **CT 104** | `jellyfin` | Jellyfin Media Server (Native QSV + CFS Priority) | Debian 12 | 4 | 1024 MB | 16 GB | `192.168.1.25` |
| **CT 105** | `deluge` | Deluge Torrent Daemon | Debian 12 | 1 | 256 MB | 8 GB | `192.168.1.26` |
| **CT 106** | `arr-stack` | Prowlarr + Radarr + Sonarr Automation | Debian 12 | 1 | 768 MB | 8 GB | `192.168.1.27` |
| **CT 108** | `tailscale` | Dedicated Subnet Router (`192.168.1.0/24`) & Exit Node | Debian 12 | 1 | 256 MB | 8 GB | `192.168.1.28` |
| **CT 107** | `hermes-agent` | Hermes AI Agent Runtime (active) | Debian 12 | 1 | 512 MB | 8 GB | `192.168.1.31` |
| **VM 200** | `rocky-lab` | Enterprise Testing Sandbox (Rocky Linux) — *planned, not yet deployed* | Rocky 9 | 2 | 2048 MB | 20 GB | `192.168.1.29` (planned) |

---

## 🗺️ Engineering Roadmap & Implementation Milestones

### Phase 1: Ingress Gateway & Core Control Plane (Completed)
- [x] **IaC Baseline:** Declarative Proxmox provider setup with pinned versions & remote API integration[cite: 12, 13].
- [x] **Core DNS & Local Resolution:** Deploy CT 100 (`pihole` - `192.168.1.21`) managing cluster-wide `.home` domains[cite: 12, 13].
- [x] **Edge Reverse Proxy:** Deploy CT 101 (`nginx` - `192.168.1.22`) handling Layer 7 routing for internal `.home` virtual hosts[cite: 12, 13].
- [x] **Control Plane & DevOps Runner:** Configure CT 102 (`Arch-server` - `192.168.1.23`) as the internal automation control plane[cite: 12, 13].
- [x] **Standardized Shell Environment:** Cross-distro CLI setup (Zsh, Starship, LSD) automated via Ansible `common_shell` role[cite: 12, 13].
- [x] **IaC Refactoring:** Modularize Terraform codebase (`modules/lxc_container`) with `for_each` data matrix and zero-downtime state migration[cite: 12, 13].
- [x] **CI/CD Quality Gates:** GitHub Actions workflow with secret scanning (Gitleaks), HCL validation, and dynamic Ansible syntax checks[cite: 12, 13].

### Phase 2: Hardware Acceleration, Media & Remote Gateway (Completed)
- [x] **Home Automation Node:** Provision CT 103 (`home-assistant` - `192.168.1.24`) compute resource via Terraform[cite: 12, 13].
- [x] **Host Power & Thermal Optimization:** Automated CPU governor scaling (`powersave`) via systemd unit and `thermald` thermal daemon to keep package temperatures controlled under high transcoding loads.
- [x] **Host Storage Management:** Persistent high-throughput NTFS storage automation (`/mnt/storage1`, `/mnt/storage2`) via Ansible[cite: 12, 13].
- [x] **GPU-Accelerated Media Streaming:** Deploy CT 104 (`jellyfin` - `192.168.1.25`) with Intel QuickSync (QSV) `/dev/dri` passthrough and host-level persistent udev rules[cite: 12, 13].
- [x] **Resource Scaling & Scheduling:** Scale CT 104 to all host CPU cores and enforce systemd scheduling overrides (`Nice=-5`, `CPUWeight=150`)[cite: 13].
- [x] **Remote Mesh Gateway:** Provision dedicated CT 108 (`tailscale` - `192.168.1.28`) with host-level `/dev/net/tun` passthrough, serving as Subnet Router (`192.168.1.0/24`) and Exit Node[cite: 12, 13].
- [x] **Network File Sharing:** Deploy declarative Samba server on CT 102 (`Arch-server`) sharing `/` with Apple Files app support via `vfs_fruit` and Avahi mDNS[cite: 12, 13].

### Phase 3: Media Acquisition & Automation Pipeline (Completed)
- [x] **Torrent Acquisition Node:** Provision CT 105 (`deluge` - `192.168.1.26`) with bind-mount access to `/mnt/storage1/downloads`[cite: 12, 13].
- [x] **Unified Routing for Deluge:** Deploy reverse proxy ingress rule `deluge.home` on CT 101[cite: 12, 13].
- [x] **Automation Stack:** Provision CT 106 (`arr-stack` - `192.168.1.27`) consolidating Prowlarr, Radarr, and Sonarr services[cite: 12, 13].
- [x] **Self-Healing Storage Pipeline:** Decouple mount definitions from Terraform state drift (`lifecycle.ignore_changes`) and enforce declarative auto-mount imports across media playbooks[cite: 13].
- [x] **Fleet-Wide Password Access:** Automate root password provisioning and OpenSSH drop-in configs (`/etc/ssh/sshd_config.d/01-permit-password.conf`) across all containers for mobile management (Termius)[cite: 13].

### Phase 4: Enterprise Linux Lab & AI Runtime (Next Target)
- [x] **AI Autonomous Agent:** Deploy CT 107 (`hermes-agent` - `192.168.1.31`) runtime container — *active*.
- [ ] **Enterprise Testing VM:** Deploy VM 200 (`rocky-lab` - `192.168.1.29`) KVM guest for RHEL sysadmin & SELinux verification[cite: 13].
- [ ] **Disaster Recovery Pipeline:** Automated Proxmox VZDump backups targeting secondary storage[cite: 13].

---
### Phase 5: Monitoring & Media Services (Planned)
- [ ] **Monitoring Stack (Prometheus + Grafana):** Deploy Prometheus for metrics collection (Proxmox exporter, nginx exporter, pihole exporter) and Grafana for visualization/dashboards/alerting. Resource estimate: Prometheus 1-2 vCPU, 512-1024 MB RAM, 10-20 GB disk; Grafana 1 vCPU, 256-512 MB RAM, 5-10 GB disk.
- [ ] **PhotoPrism:** Deploy self-hosted photo management with AI tagging, facial recognition, geo-location. Resource estimate: min 2 vCPU, 1024 MB RAM, 20 GB disk; recommended 4 vCPU, 2048-4096 MB RAM, 50+ GB disk for AI features. Nginx ingress at `photoprism.home` via CT 101 reverse proxy.

---

## 📂 Repository Layout

```text
Homelab-Proxmox/
├── .github/workflows/ci.yaml       # Automated CI Quality Gates (Gitleaks, Terraform, Ansible)
├── .gitattributes
├── .gitignore                       # Excludes .tfstate, *.tfvars, .terraform/
├── README.md                        # System Architecture Blueprint & Roadmap
├── docs/                            # Documentation (placeholder)
│   └── .gitkeep
├── terraform/                       # Day 0 Compute Provisioning
│   ├── .terraform/                  # (gitignored) providers, modules cache
│   ├── .terraform.lock.hcl          # Provider version lock file
│   ├── terraform.tfstate            # (gitignored) state
│   ├── terraform.tfstate.backup     # (gitignored) state backup
│   ├── tfplan                        # (gitignored) planned actions
│   ├── versions.tf                   # Provider & terraform version constraints
│   ├── variables.tf                  # Input variable declarations
│   ├── moved.tf                      # Terraform moved blocks (state migration)
│   ├── containers.tf                 # LXC/CT & VM declaration (data matrix + module call)
│   └── modules/lxc_container/       # Reusable container module
│       ├── main.tf
│       ├── variables.tf
│       └── versions.tf
└── ansible/                         # Day 1 & Day 2 Configuration Management
    ├── ansible.cfg
    ├── inventory/
    │   ├── .gitkeep
    │   └── hosts.yaml                # Unified Core Infrastructure Inventory
    ├── playbooks/                   # Orchestration playbooks (ordered by execution dependency)
    │   ├── configure-pve-gpu.yaml       # Intel iGPU render node passthrough
    │   ├── configure-pve-power.yaml     # Host CPU governor & thermald management
    │   ├── configure-pve-storage.yaml   # High-throughput storage automation
    │   ├── configure-tailscale-lxc.yaml # PVE TUN device passthrough setup
    │   ├── set-root-password.yaml       # Fleet-wide mobile administration
    │   ├── deploy-shell.yaml            # Common Zsh/Starship environment
    │   ├── deploy-pihole.yaml           # Core DNS orchestration
    │   ├── deploy-nginx.yaml            # Ingress proxy configuration
    │   ├── deploy-homeassistant.yaml    # IoT runtime deployment
    │   ├── deploy-jellyfin.yaml         # Transcoding & media platform
    │   ├── deploy-deluge.yaml           # Torrent download engine
    │   ├── deploy-arr.yaml              # Media indexer & stack orchestration
    │   ├── deploy-tailscale.yaml        # Subnet routing configuration
    │   ├── deploy-samba.yaml            # iOS-optimized file sharing
    │   └── deploy-adguard.yaml          # AdGuard Home deployment (role present, playbook TBD)
    └── roles/                        # Reusable Ansible roles
        ├── adguard/                   # AdGuard Home
        │   ├── defaults/main.yaml
        │   ├── handlers/main.yaml
        │   ├── tasks/main.yaml
        │   └── templates/AdGuardHome.yaml.j2
        ├── arr_stack/                 # Prowlarr + Radarr + Sonarr
        │   ├── handlers/main.yaml
        │   └── tasks/main.yaml
        ├── common_shell/              # Zsh/Starship/LSD environment
        │   ├── files/starship.toml
        │   ├── files/zshrc
        │   └── tasks/main.yaml
        ├── deluge/                    # BitTorrent daemon & web UI
        │   ├── handlers/main.yaml
        │   └── tasks/main.yaml
        ├── homeassistant/             # Home Assistant Core (Python venv)
        │   ├── defaults/main.yaml
        │   ├── handlers/main.yaml
        │   ├── tasks/main.yaml
        │   └── templates/configuration.yaml.j2
        ├── jellyfin/                  # Media server (apt repo + systemd)
        │   ├── handlers/main.yaml
        │   └── tasks/main.yaml
        ├── nginx/                     # Ingress routing & virtual hosts
        │   ├── handlers/main.yaml
        │   ├── tasks/main.yaml
        │   └── templates/vhost.conf.j2
        ├── pihole/                    # Pi-hole v6 unattended installer
        │   ├── defaults/main.yaml
        │   ├── handlers/main.yaml
        │   ├── tasks/main.yaml
        │   └── templates/custom.list.j2
        │   └── templates/setupVars.conf.j2
        ├── samba_server/              # iOS-optimized Samba & Avahi mDNS
        │   ├── handlers/main.yaml
        │   ├── tasks/main.yaml
        │   └── templates/smb.conf.j2
        └── tailscale_node/            # Tailscale subnet router & IP forwarding
            ├── defaults/main.yaml
            └── tasks/main.yaml
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

### 2. Configure Host Devices, Power, Storage & Access (Ansible Day 1)
```bash
cd ../ansible
# Host Power Management & Thermal Controls
ansible-playbook -i inventory/hosts.yaml playbooks/configure-pve-power.yaml

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
