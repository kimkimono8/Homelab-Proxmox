# Project Context & AI Persona Guidelines: Homelab Proxmox (IaC & GitOps)

## 📌 Project Overview
- **Repository:** `Homelab-Proxmox`
- **Nature:** Enterprise-grade Homelab engineered via Infrastructure as Code (Terraform) and Configuration Management (Ansible) under a strict GitOps discipline.
- **Physical Host Hardware:** MSI PRO H610M-E DDR4 — Intel Core i3-12100 (12th Gen, 4C/8T, max 4.3 GHz), 8GB DDR4-2400 MHz, Samsung 970 EVO Plus 250GB NVMe, 3× 1TB internal SATA HDD + 2× 1TB external USB HDD (5-disk pool), 750W 80+ Bronze PSU.
- **Hardware Constraints & Tuning:** Strict 8GB host RAM budget. All services must be optimized for low memory footprint using Unprivileged LXCs, kernel namespaces, CPU governor `powersave`, and `thermald`.
- **Virtualization Model:** 1:1 lightweight LXC container architecture with 1 planned KVM Virtual Machine (`rocky-lab`).
- **Development & Control Station:** MacBook Air (`adminx@adminxs-MacBook-Air.local`) acting as the primary execution workstation.
- **Storage & SSD Preservation Rule:** All Git, Terraform, and Ansible operations must be executed directly within the SMB network share path (`/Volumes/mnt-server/backup/projects/Homelab-Proxmox`) to preserve the MacBook's internal SSD lifespan.

---

## 🌐 Network & Infrastructure Matrix (Subnet: `192.168.1.0/24`)
- `192.168.1.20`: Physical Host (`pve`) — Proxmox VE Hypervisor (GUI `:8006`), Storage, Hardware Passthrough
- `192.168.1.21`: CT 100 (`pihole`) — Pi-hole v6 Core DNS Resolver for internal `*.home` domains
- `192.168.1.22`: CT 101 (`nginx`) — Edge Ingress & Reverse Proxy Router
- `192.168.1.23`: CT 102 (`Arch-server`) — Dedicated Apple Samba Server & File Gateway (`vfs_fruit`, Avahi mDNS)
- `192.168.1.24`: CT 103 (`home-assistant`) — Home Assistant Core (Python venv via `uv`)
- `192.168.1.25`: CT 104 (`jellyfin`) — Media Server (Intel UHD 730 QSV VA-API passthrough, CFS CPUWeight)
- `192.168.1.26`: CT 105 (`deluge`) — BitTorrent Daemon & Web UI
- `192.168.1.27`: CT 106 (`arr-stack`) — Prowlarr, Radarr, Sonarr, FlareSolverr (v3.5.2 binary)
- `192.168.1.28`: CT 108 (`tailscale`) — Dedicated Subnet Router (`192.168.1.0/24`) & Exit Node
- `192.168.1.31`: CT 107 (`hermes-agent`) — Autonomous AI Agent CLI Runtime
- `192.168.1.32`: CT 109 (`monitoring`) — Prometheus, Alertmanager, Grafana Stack
- `192.168.1.33`: CT 110 (`photoprism`) — PhotoPrism Standalone Engine
- `192.168.1.29`: VM 200 (`rocky-lab`) — Rocky Linux 9 Enterprise Testing VM (planned)

---

## 🛠️ Tooling & Separation of Concerns
1. **Terraform (Day 0 Compute):** Used exclusively for compute provisioning, LXC container/VM lifecycle, CPU/RAM/swap/disk specs, and SSH public key injection into Proxmox VE.
   * *Lifecycle Protection:* Bind mounts remain decoupled from Terraform drift via `lifecycle.ignore_changes = [mount_point, description]`.
2. **Ansible (Day 1 & Day 2):** Used for host device passthrough (GPU, TUN), CPU power/thermal management, 5-disk persistent storage mounts (`/etc/fstab` + LXC `mp0`–`mp4`), OS tuning, systemd units, and service deployments.
3. **Execution Workstation (MacBook):** Automation commands (`terraform apply`, `ansible-playbook`) are executed from the MacBook CLI directly over the network mount.
4. **Secret Boundary:** Never commit secrets, `.tfstate`, `*.tfvars`, `*.key`, `*.pem`, `id_*`, or `.env` files to Git.

---

## 📐 GitOps & Development Standards
- **Branch-Based Workflow:** Strictly forbid direct commits to `main`. Every change must be developed in a dedicated branch (`feat/...`, `fix/...`, `docs/...`) and merged via Pull Requests.
- **Conventional Commits:** Maintain clean, structured commit history following Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`).
- **Anti-ClickOps / No Manual Edits:** Never perform ad-hoc changes via Proxmox Web GUI or direct shell without codifying them into Terraform or Ansible first. The Git repository is the Single Source of Truth (SSOT).
- **macOS SMB Cleanliness:** Always exclude macOS metadata (`.DS_Store`, `._*`) via `.gitignore`.
- **Zero Documentation Drift:** Keep `README.md` strictly synchronized with all architecture, IP, storage, and resource changes.

---

## ⚠️ Mandatory AI Behavioral Rules
1. **Explain and Teach:** Explain concepts, command flags, and underlying mechanics step-by-step. Do not provide raw copy/paste commands without technical context.
2. **Never Assume Storage or File Layouts:** Always verify disk layouts, UUIDs, mount points, and permissions before generating storage-related code.
3. **No Unrequested Scope Expansion:** Never invent or insert unplanned services or roadmap items without explicit instruction.
4. **Naming & Identity Consistency:** Name all resources, directories, and files after their specific self-hosted service role. Enforce UID/GID 1000 across all media/shared storage services.
5. **Preserve Documentation Integrity:** Ensure Markdown updates in `README.md` preserve all required sections (Matrix, Roadmap, Layout, Quickstart) without truncation.
6. **Network Drive Integrity:** Always execute file and command operations on the network path `/Volumes/mnt-server/backup/projects/Homelab-Proxmox`.
