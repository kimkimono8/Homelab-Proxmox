# Homelab Proxmox (IaC & GitOps)

Infrastructure as Code and GitOps repository for personal homelab running on Proxmox VE (Dell 5290 - 8GB RAM / 256GB SSD).

## Network & IP Allocations (Subnet: 192.168.1.0/24)

| Host / VMID | Hostname | IP Address | Services | Memory |
| :--- | :--- | :--- | :--- | :--- |
| **Physical Host** | pve | 192.168.1.20 | Proxmox VE Hypervisor (GUI :8006) | ~1000 MB |
| **CT 100 (LXC)** | adguard | 192.168.1.21 | AdGuard Home (DNS Resolver) | 128 MB |
| **CT 101 (LXC)** | npm | 192.168.1.22 | Nginx Proxy Manager (Reverse Proxy) | 256 MB |
| **CT 102 (LXC)** | Arch-server | 192.168.1.23 | Ansible Control Node & Remote Workstation | 512 MB |
| **CT 103 (LXC)** | home-assistant | 192.168.1.24 | Home Assistant Core | 512 MB |
| **CT 104 (LXC)** | jellyfin | 192.168.1.25 | Jellyfin Media Server | 1024 MB |
| **CT 105 (LXC)** | deluge | 192.168.1.26 | Deluge Torrent Daemon | 256 MB |
| **CT 106 (LXC)** | arr-stack | 192.168.1.27 | Prowlarr + Radarr + Sonarr + FlareSolverr | 768 MB |
| **CT 107 (LXC)** | hermes-agent | 192.168.1.28 | Hermes AI Agent Runtime | 512 MB |
| **VM 200 (VM)** | rocky-lab | 192.168.1.29 | Enterprise Testing (Rocky Linux) | 2048 MB |
