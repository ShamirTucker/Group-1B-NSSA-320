output "resource_group_name" {
  description = "Resource group containing the project."
  value       = azurerm_resource_group.project.name
}

output "vm_private_ips" {
  description = "Private IP addresses assigned to the three project VMs."
  value = {
    for name, nic in azurerm_network_interface.vm : name => nic.private_ip_address
  }
}

output "ansible_control_public_ip" {
  description = "Public IP used to SSH into the Ansible control node."
  value       = azurerm_public_ip.vm["hades"].ip_address
}

output "wordpress_public_ip" {
  description = "Public IP used to reach the WordPress webserver."
  value       = azurerm_public_ip.vm["thanatos"].ip_address
}

output "database_private_ip" {
  description = "Private-only IP address of the MariaDB server."
  value       = azurerm_network_interface.vm["hypnos"].private_ip_address
}

output "ssh_commands" {
  description = "SSH commands for the two VMs with public IP addresses."
  value = {
    ansible_control = "ssh ${var.admin_username}@${azurerm_public_ip.vm["hades"].ip_address}"
    wordpress       = "ssh ${var.admin_username}@${azurerm_public_ip.vm["thanatos"].ip_address} (SSH is allowed only from the Ansible control node)"
  }
}

output "ansible_inventory" {
  description = "Inventory content for Ansible running from hades. Save this as inventory.inv on the control node."
  value = <<-EOT
    [webservers]
    thanatos ansible_host=${azurerm_network_interface.vm["thanatos"].private_ip_address}

    [dbservers]
    hypnos ansible_host=${azurerm_network_interface.vm["hypnos"].private_ip_address}

    [all:vars]
    ansible_user=${var.admin_username}
    EOT
}
