variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "location" {
  description = "Azure region. Confirm the VM size and quota are available here."
  type        = string
  default     = "mexicocentral"
}

variable "prefix" {
  description = "Prefix for all resource names."
  type        = string
  default     = "nssa320-g8"
}

variable "vnet_cidr" {
  description = "Address space of the virtual network."
  type        = string
  default     = "192.168.100.0/24"
}

variable "subnet_cidr" {
  description = "Subnet holding all three VMs. Hosts are placed at .4, .5, .6 (Azure reserves .0-.3)."
  type        = string
  default     = "192.168.100.0/24"
}

variable "vm_names" {
  description = "Hostnames for the three VMs."
  type = object({
    control = string
    web     = string
    db      = string
  })
  default = {
    control = "hades"
    web     = "thanatos"
    db      = "hypnos"
  }
}

variable "vm_size" {
  description = "Azure VM size for all VMs."
  type        = string
  default     = "Standard_B2als_v2"
}

variable "admin_username" {
  description = "Admin username on all VMs."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key installed on every VM."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "admin_cidr" {
  description = "Source IP/CIDR allowed to SSH to the control node (e.g. your campus/home public IP as x.x.x.x/32)."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid CIDR such as 203.0.113.10/32."
  }
}

variable "os_disk_type" {
  description = "OS disk storage type."
  type        = string
  default     = "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB."
  type        = number
  default     = 30
}

variable "image" {
  description = "Marketplace image reference. Verify with: az vm image list --all --publisher resf --offer rockylinux-x86_64 -o table"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-base"
    version   = "latest"
  }
}

variable "plan" {
  description = "Marketplace plan block required by the Rocky image. Set to null for images that need none."
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  nullable = true
  default = {
    name      = "9-base"
    product   = "rockylinux-x86_64"
    publisher = "resf"
  }
}

variable "extra_tags" {
  description = "Additional tags merged onto every resource."
  type        = map(string)
  default     = {}
}
