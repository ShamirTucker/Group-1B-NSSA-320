locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

# Rocky Linux 9 Marketplace image.
# The agreement resource below records acceptance of the Marketplace terms.
resource "azurerm_marketplace_agreement" "rocky_linux_9" {
  publisher = "resf"
  offer     = "rockylinux-x86_64"
  plan      = "9-base"
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = local.vms

  name                = each.value.hostname
  computer_name       = each.value.hostname
  resource_group_name = data.azurerm_resource_group.project.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.vm[each.key].id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-base"
    version   = "latest"
  }

  plan {
    name      = "9-base"
    publisher = "resf"
    product   = "rockylinux-x86_64"
  }

  os_disk {
    name                 = "osdisk-${each.key}-nssa320"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {}

  tags = merge(var.tags, {
    hostname = each.value.hostname
    purpose  = each.value.purpose
  })

  depends_on = [
    azurerm_marketplace_agreement.rocky_linux_9
  ]
}
