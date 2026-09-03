# Homelab Proxmox (IaC & GitOps)

Infrastructure as Code and GitOps repository for personal homelab running on Proxmox VE (Dell 5290 - 8GB RAM / 256GB SSD).

## Node Allocations (1:1 Service Mapping)

| VMID / Type | Hostname | Services | Memory |
| :--- | :--- | :--- | :--- |
| **VM 200 (VM)** | rocky-lab | Rocky Linux (Enterprise Testing) | 2048 MB |
| **CT 100 (LXC)** | adguard | AdGuard Home (DNS & Ingress Base) | 128 MB |
| **CT 101 (LXC)** | npm | Nginx Proxy Manager (Reverse Proxy) | 256 MB |
| **CT 102 (LXC)** | control-node | Ansible Control Node & GitOps Manager | 512 MB |
| **CT 103 (LXC)** | home-assistant | Home Assistant Core | 512 MB |
| **CT 104 (LXC)** | jellyfin | Jellyfin Media Server | 1024 MB |
| **CT 105 (LXC)** | deluge | Deluge Torrent Daemon | 256 MB |
| **CT 106 (LXC)** | arr-stack | Prowlarr + Radarr + Sonarr + FlareSolverr | 768 MB |
| **CT 107 (LXC)** | hermes-agent | Hermes AI Agent Runtime | 512 MB |
