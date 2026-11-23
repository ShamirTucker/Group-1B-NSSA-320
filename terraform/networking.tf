locals {
  vms = {
    hades = {
      hostname          = "hades"
      private_ip        = "192.168.100.10"
      purpose           = "Ansible control node"
      public_ip         = true
    }
    thanatos = {
      hostname          = "thanatos"
      private_ip        = "192.168.100.11"
      purpose           = "WordPress webserver"
      public_ip         = true
    }
    hypnos = {
      hostname          = "hypnos"
      private_ip        = "192.168.100.12"
      purpose           = "MariaDB database server"
      public_ip         = false
    }
  }

  nsg_rules = {
    hades = [
      {
        name                       = "Allow-SSH-From-Admin"
        priority                   = 100
        protocol                   = "Tcp"
        destination_port_range     = "22"
        source_address_prefix      = var.admin_source_cidr
        destination_address_prefix = "*"
      },
      {
        name                       = "Deny-SSH-From-Virtual-Network"
        priority                   = 200
        protocol                   = "Tcp"
        destination_port_range     = "22"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
    ]
    thanatos = [
      {
        name                       = "Allow-HTTP"
        priority                   = 100
        protocol                   = "Tcp"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-HTTPS"
        priority                   = 110
        protocol                   = "Tcp"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-SSH-From-Ansible"
        priority                   = 120
        protocol                   = "Tcp"
        destination_port_range     = "22"
        source_address_prefix      = "192.168.100.10/32"
        destination_address_prefix = "*"
      },
      {
        name                       = "Deny-SSH-From-Virtual-Network"
        priority                   = 130
        protocol                   = "Tcp"
        destination_port_range     = "22"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
    ]
    hypnos = [
      {
        name                       = "Allow-MariaDB-From-WordPress"
        priority                   = 100
        protocol                   = "Tcp"
        destination_port_range     = "3306"
        source_address_prefix      = "192.168.100.11/32"
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-SSH-From-Ansible"
        priority                   = 110
        protocol                   = "Tcp"
        destination_port_range     = "22"
        source_address_prefix      = "192.168.100.10/32"
        destination_address_prefix = "*"
      },
      {
        name                       = "Deny-MariaDB-From-Other-VNet-Hosts"
        priority                   = 120
        protocol                   = "Tcp"
        destination_port_range     = "3306"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      },
      {
        name                       = "Deny-SSH-From-Virtual-Network"
        priority                   = 130
        protocol                   = "Tcp"
        destination_port_range     = "22"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
    ]
  }
}

resource "azurerm_public_ip" "vm" {
  for_each = {
    for name, vm in local.vms : name => vm if vm.public_ip
  }

  name                = "pip-${each.key}-nssa320"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_security_group" "vm" {
  for_each = local.vms

  name                = "nsg-${each.key}-nssa320"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = local.nsg_rules[each.key]

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_network_interface" "vm" {
  for_each = local.vms

  name                = "nic-${each.key}-nssa320"
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.project.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip
    public_ip_address_id          = each.value.public_ip ? azurerm_public_ip.vm[each.key].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "vm" {
  for_each = local.vms

  network_interface_id      = azurerm_network_interface.vm[each.key].id
  network_security_group_id = azurerm_network_security_group.vm[each.key].id
}
