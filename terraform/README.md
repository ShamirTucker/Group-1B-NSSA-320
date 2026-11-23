# NSSA-320 Group 8 — Small Business Web Application (Terraform)

- One virtual network: `192.168.100.0/24`
- Three Rocky Linux 9 virtual machines:
  - `hades`: Ansible control node
  - `thanatos`: WordPress webserver
  - `hypnos`: MariaDB database server
- Static private IP addresses
- Public IPs for the Ansible control node and WordPress webserver
- One Network Security Group per VM
- SSH-key authentication (password authentication disabled)

This configuration keeps the same `/24` network but uses:

| Device | Address |
|---|---|
| Azure subnet default gateway | `192.168.100.1` (Azure-managed; not a VM) |
| hades — Ansible control | `192.168.100.10` |
| thanatos — WordPress | `192.168.100.11` |
| hypnos — MariaDB | `192.168.100.12` |
| `.254` | Unused; available for a future network design |


## Network security

| VM | Inbound port | Allowed source |
|---|---:|---|
| hades | TCP 22 | `admin_source_cidr` in `terraform.tfvars` |
| thanatos | TCP 80, 443 | Internet |
| thanatos | TCP 22 | hades private IP only |
| hypnos | TCP 3306 | thanatos private IP only; other VNet sources explicitly denied |
| hypnos | TCP 22 | hades private IP only; other VNet sources explicitly denied |


## Files

- `versions.tf` — Terraform and provider version requirements
- `provider.tf` — AzureRM provider configuration
- `variables.tf` — reusable project inputs
- `main.tf` — lookup of the existing resource group, VNet, and subnet
- `networking.tf` — private/public IPs, NICs, NSGs, and security rules
- `virtual_machines.tf` — Rocky Linux Marketplace agreement and Linux VMs
- `outputs.tf` — VM addresses, SSH commands, and Ansible inventory
- `terraform.tfvars.example` — example local configuration
- `.gitignore` — excludes state, local secrets, and generated files
