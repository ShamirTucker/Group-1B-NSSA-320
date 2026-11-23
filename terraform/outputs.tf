output "resource_group" {
  value = azurerm_resource_group.main.name
}

output "vm_names" {
  value = { for k, v in module.vm : k => v.name }
}

output "private_ips" {
  description = "Private IPs Ansible uses between hosts."
  value       = { for k, v in module.vm : k => v.private_ip }
}

output "public_ips" {
  description = "Public IPs (control = SSH entry point, web = WordPress site)."
  value       = { for k, v in module.vm : k => v.public_ip }
}

output "wordpress_url" {
  value = "http://${module.vm["web"].public_ip}"
}

output "ssh_to_control" {
  value = "ssh ${var.admin_username}@${module.vm["control"].public_ip}"
}
