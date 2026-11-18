variable "project_name" {
  description = "Short prefix used in Azure resource names."
  type        = string
  default     = "nssa320"
}

variable "location" {
  description = "Azure region. Confirm the selected VM size is available in this region."
  type        = string
  default     = "mexicocentral"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
  default     = "rg-nssa320-webapp"
}

variable "vm_size" {
  description = "Azure VM size for both Linux servers."
  type        = string
  default     = "Standard_B2als_v2"
}

variable "admin_username" {
  description = "Linux administrator account created on both VMs."
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key_path" {
  description = "Local path to the SSH public key file."
  type        = string
}

variable "ansible_control_cidr" {
  description = "Public IP/CIDR of the existing Ansible control node, e.g. 203.0.113.10/32."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the project virtual network."
  type        = string
  default     = "10.32.0.0/16"
}

variable "web_subnet_prefix" {
  description = "Address prefix for the webserver subnet."
  type        = string
  default     = "10.32.1.0/24"
}

variable "db_subnet_prefix" {
  description = "Address prefix for the database subnet."
  type        = string
  default     = "10.32.2.0/24"
}

variable "rocky_publisher" {
  type    = string
  default = "resf"
}

variable "rocky_offer" {
  type    = string
  default = "rockylinux-x86_64"
}

variable "rocky_sku" {
  type    = string
  default = "9-base"
}
