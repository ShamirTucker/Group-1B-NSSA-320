output "resource_group_name" {
  value = azurerm_resource_group.project.name
}

output "webserver_public_ip" {
  description = "Public IP used to open the WordPress website and connect from Ansible."
  value       = azurerm_public_ip.web.ip_address
}

output "webserver_private_ip" {
  value = azurerm_network_interface.web.private_ip_address
}

output "database_private_ip" {
  value = azurerm_network_interface.database.private_ip_address
}

output "webserver_vm_name" {
  value = azurerm_linux_virtual_machine.web.name
}

output "database_vm_name" {
  value = azurerm_linux_virtual_machine.database.name
}

output "ssh_username" {
  value = var.admin_username
}
