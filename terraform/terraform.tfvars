# Copy this file to terraform.tfvars and replace the example SSH source CIDR.
location            = "mexicocentral"
resource_group_name = "Group_1B_NSSA_320"
vm_size             = "Standard_B2als_v2"

# IMPORTANT: Replace with your current public IPv4 address followed by /32.
# Example documentation-only address below will NOT allow your actual connection.
admin_source_cidr = "203.0.113.10/32"

# Change this if your public key is stored elsewhere.
ssh_public_key_path = "~/.ssh/id_rsa.pub"

admin_username = "azureuser"
