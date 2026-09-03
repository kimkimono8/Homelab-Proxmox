moved {
  from = proxmox_virtual_environment_container.adguard
  to   = module.containers["adguard"].proxmox_virtual_environment_container.this
}

moved {
  from = proxmox_virtual_environment_container.nginx
  to   = module.containers["nginx"].proxmox_virtual_environment_container.this
}

moved {
  from = proxmox_virtual_environment_container.homeassistant
  to   = module.containers["homeassistant"].proxmox_virtual_environment_container.this
}
