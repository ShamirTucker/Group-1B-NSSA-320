variable "location" {
  description = "Azure region. Mexico Central is the region selected for this project."
  type        = string
  default     = "mexicocentral"
}

variable "resource_group_name" {
  description = "Name of the resource group that contains the project."
  type        = string
  default     = "rg-nssa320-group8"
}

variable "vnet_name" {
  description = "Name of the Azure virtual network."
  type        = string
  default     = "vnet-nssa320-group8"
}

variable "address_space" {
  description = "Virtual network address space."
  type        = list(string)
  default     = ["192.168.100.0/24"]
}

variable "subnet_name" {
  description = "Name of the subnet containing the three project VMs."
  type        = string
  default     = "snet-project"
}

variable "subnet_prefixes" {
  description = "Address prefixes for the project subnet."
  type        = list(string)
  default     = ["192.168.100.0/24"]
}

variable "vm_size" {
  description = "Azure VM size. This matches the size proposed by the team; verify regional availability and quota before deployment."
  type        = string
  default     = "Standard_B2als_v2"
}

variable "admin_username" {
  description = "Linux administrator account created on all VMs."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Local path to the SSH public key used for all VMs."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "admin_source_cidr" {
  description = "Public IPv4 CIDR allowed to SSH to the Ansible control node. Use your public IP with /32, for example 198.51.100.25/32."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_source_cidr, 0)) && var.admin_source_cidr != "0.0.0.0/0"
    error_message = "Set admin_source_cidr to a valid, restricted CIDR. Do not expose SSH to 0.0.0.0/0."
  }
}

variable "tags" {
  description = "Tags applied to Azure resources."
  type        = map(string)
  default = {
    project     = "NSSA-320-Group-8"
    environment = "school-project"
    managed_by  = "terraform"
  }
}
