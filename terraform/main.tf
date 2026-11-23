resource "azurerm_resource_group" "project" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "project" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = azurerm_resource_group.project.location
  resource_group_name = azurerm_resource_group.project.name
  tags                = var.tags
}

resource "azurerm_subnet" "project" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.project.name
  virtual_network_name = azurerm_virtual_network.project.name
  address_prefixes     = var.subnet_prefixes
}
