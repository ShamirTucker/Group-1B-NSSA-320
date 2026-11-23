# NSSA-320 Group 8 — Small Business Web Application (Terraform)

This Terraform configuration deploys the Azure infrastructure for the Group 8 WordPress/MariaDB project.

## What it creates

* One Azure resource group
* One virtual network: `192.168.100.0/24`
* One subnet
* Three Rocky Linux 9 virtual machines:

  * `hades`: Ansible control node
  * `thanatos`: WordPress webserver
  * `hypnos`: MariaDB database server
* Static private IP addresses
* Public IPs for the Ansible control node and WordPress webserver
* No public IP for the MariaDB server
* One Network Security Group per VM
* SSH-key authentication (password authentication disabled)
* Rocky Linux 9 Marketplace agreement



This configuration keeps the same `/24` network but uses:

|Device|Address|
|-|-|
|Azure subnet default gateway|`192.168.100.1` (Azure-managed; not a VM)|
|hades — Ansible control|`192.168.100.10`|
|thanatos — WordPress|`192.168.100.11`|
|hypnos — MariaDB|`192.168.100.12`|
|`.254`|Unused; available for a future network design|

Update the team's architecture diagram and Ansible variables/inventory to use these actual Azure addresses.

## Network security

Inbound rules are deliberately limited:

|VM|Inbound port|Allowed source|
|-|-:|-|
|hades|TCP 22|`admin\_source\_cidr` in `terraform.tfvars`|
|thanatos|TCP 80, 443|Internet|
|thanatos|TCP 22|hades private IP only|
|hypnos|TCP 3306|thanatos private IP only; other VNet sources explicitly denied|
|hypnos|TCP 22|hades private IP only; other VNet sources explicitly denied|

Azure NSGs also retain their default outbound rules. The database VM has no public IP. SSH access to the web and database VMs is intended to be initiated from the Ansible control node over the private network.

## Prerequisites

1. An Azure subscription with permission to create resource groups, networking resources, public IPs, and VMs.
2. Azure CLI installed and logged in.
3. Terraform CLI installed (1.9 or later).
4. An SSH key pair on the computer running Terraform.
5. Sufficient regional VM quota and availability in `mexicocentral`.

### Authenticate to Azure

```bash
az login
az account set --subscription "<YOUR\_SUBSCRIPTION\_ID>"
az account show --output table
```

If you do not already have an SSH key:

```bash
ssh-keygen -t rsa -b 4096 -f \~/.ssh/id\_rsa
```

You can use an existing supported SSH key instead. The public key file must exist at the path set in `ssh\_public\_key\_path`.

### Check VM size availability and quota

The proposal selected `Standard\_B2als\_v2`. Azure SKU availability and quota vary by region and subscription. Check before applying:

```bash
az vm list-skus \\
  --location mexicocentral \\
  --size Standard\_B2als\_v2 \\
  --all \\
  --output table
```

If that size is unavailable or your subscription lacks quota, choose a supported size and update `vm\_size` in `terraform.tfvars`. `Standard\_B2s` is an alternative to check, not a guarantee of availability.

Also verify that the Rocky Linux Marketplace image is available:

```bash
az vm image list \\
  --location mexicocentral \\
  --publisher resf \\
  --offer rockylinux-x86\_64 \\
  --sku 9-base \\
  --all \\
  --output table
```

The first deployment may require Marketplace terms acceptance. Terraform includes an `azurerm\_marketplace\_agreement` resource to record acceptance. Review the Rocky Linux Marketplace terms for your subscription before applying.

## Deployment

Run these commands from this `terraform/` directory.

### 1\. Create your local variables file

Linux/macOS:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Windows PowerShell:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and replace `203.0.113.10/32` with your actual public IPv4 address in `/32` format. You can check your public IP using a trusted IP-checking service. Do not use `0.0.0.0/0` for SSH.

Confirm `ssh\_public\_key\_path` points to your public key file.

### 2\. Initialize Terraform

```bash
terraform init
```

This downloads the AzureRM provider and creates `.terraform.lock.hcl`. Commit the lock file to Git.

### 3\. Format and validate

```bash
terraform fmt -recursive
terraform validate
```

### 4\. Review the deployment plan

```bash
terraform plan -out group8.tfplan
```

Review the plan. It should show the resource group, VNet, subnet, public IPs, NSGs, NICs, and three Linux VMs.

### 5\. Deploy

```bash
terraform apply group8.tfplan
```

### 6\. Review outputs

```bash
terraform output
terraform output -raw ansible\_control\_public\_ip
terraform output -raw wordpress\_public\_ip
terraform output -raw ansible\_inventory
```

Connect to the Ansible control node:

```bash
ssh azureuser@<ANSIBLE\_CONTROL\_PUBLIC\_IP>
```

The `ansible\_inventory` output is intended to be saved as `inventory.inv` on `hades`, where Ansible can reach the web and database VMs through their private IP addresses.

## Ansible connection notes

* Copy the private SSH key securely to the control node, or use a controlled SSH-agent/key-forwarding approach. Never commit private keys to Git.
* The public key configured by Terraform is installed on all three VMs.
* Ensure the Ansible control node can SSH to the web and database nodes using their private addresses.
* Your Ansible playbooks should configure the host firewalls as well as the Azure NSGs. Azure NSGs are an additional network layer, not a replacement for host firewall configuration.
* The MariaDB server should listen on the private interface and allow the WordPress host only. The Ansible database role should create a database user with privileges limited to the WordPress database.

## Useful commands

```bash
# Show current state
terraform show

# Preview drift
terraform plan

# List managed resources
terraform state list

# Re-apply changes
terraform apply

# Destroy all resources created by this configuration
terraform destroy
```

## Cost and cleanup

Azure resources can incur charges while running, especially VMs and public IPs. Stop using the environment when it is not needed and destroy it after the project demonstration if it is no longer required:

```bash
terraform destroy
```

Review the destroy plan and confirm before proceeding. Terraform state and the `.terraform` directory are local working data; do not commit state files or secrets to Git.

## Files

* `versions.tf` — Terraform and provider version requirements
* `provider.tf` — AzureRM provider configuration
* `variables.tf` — reusable project inputs
* `main.tf` — resource group, VNet, and subnet
* `networking.tf` — private/public IPs, NICs, NSGs, and security rules
* `virtual\_machines.tf` — Rocky Linux Marketplace agreement and Linux VMs
* `outputs.tf` — VM addresses, SSH commands, and Ansible inventory
* `terraform.tfvars.example` — example local configuration
* `.gitignore` — excludes state, local secrets, and generated files

