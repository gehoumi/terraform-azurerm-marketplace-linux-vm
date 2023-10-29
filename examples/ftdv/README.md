# Deploy Cisco FTDv Threat Defense Virtual on Azure using Terraform module

The Secure Firewall Threat Defense Virtual is integrated into the Microsoft Azure marketplace and cisco official documentation is [here](https://www.cisco.com/c/en/us/td/docs/security/firepower/quick_start/consolidated_ftdv_gsg/ftdv-gsg/m-ftdv-azure-gsg.html).


##  How to find an image in Marketplace

You must first obtain the following IDs from : Offer, Publisher, SKU, and Version. 
This can be done from Azure CLI using the following command with the provider name, example for cisco :

```bash
# Find cisco ftdv images
az vm image list -o table --publisher cisco --offer cisco-ftdv --all
  
```

## Prerequisites

Threat defense virtual deploys with 4 vNICs by default.
- Management interface—Used to connect the threat defense virtual to the Secure Firewall Management Center.
- Diagnostic interface—Used for diagnostics and reporting; cannot be used for through traffic.
- Inside interface (required)—Used to connect the threat defense virtual to inside hosts.
- Outside interface (required)—Used to connect the threat defense virtual to the public network.

## Usage

```bash
module "ftdv" {
  source = "../.."

  name                         = "FTDv"
  resource_group_name          = "cloudops"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-ftdv"
    publisher = "cisco"
    sku       = "ftdv-azure-byol"
    version   = "74.1.132"
  }
  boot_diagnostics = true
}
```

### Deployment Steps

* (optional) authenticate to AzureRM, switch to the Subscription of your choice if necessary
* initialize the Terraform module:

      terraform init

* (optional) plan you infrastructure to see what will be actually deployed:

      terraform plan

* deploy the infrastructure (you will have to confirm it with typing in `yes`):

      terraform apply

  The deployment takes couple of minutes. At the end you should see a summary similar to this:

      Apply complete! Resources: 19 added, 0 changed, 0 destroyed.

    Outputs:

    password = <sensitive>
    private_ip_addresses = {
      "if-nic0" = "10.100.0.4"
      "if-nic1" = "10.100.1.4"
      "if-nic2" = "10.100.2.4"
      "if-nic3" = "10.100.3.4"
    }
    public_ip_addresses = {
      "if-nic0" = "20.25.23.54"
      "if-nic1" = "null"
      "if-nic2" = "null"
      "if-nic3" = "null"
    }
    subnet_cidrs = {
      "if-nic0" = "10.100.0.0/24"
      "if-nic1" = "10.100.1.0/24"
      "if-nic2" = "10.100.2.0/24"
      "if-nic3" = "10.100.3.0/24"
    }

* at this stage you have to wait couple of minutes for ftdv to bootstrap.

### Post deploy and initial configuration

Complete the Threat Defense Initial Configuration Using the CLI, either from Azure console port or using SSH to the Management interface. The module creates a password used to login the host vm shell, but you need to use cisco default password for initial setup.

* Retrieve the created password:

      terraform output password:


* SSH the FTDv using cisco default username `admin` and the password `Admin123`:

      ssh admin@<management public ip>

* Example of output:

```bash
 % ssh admin@20.25.23.54
The authenticity of host '20.25.23.54 (20.25.23.54)' can't be established.
ED25519 key fingerprint is SHA256:v/MssdfG+elrtyztgymdbkqxs.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '20.25.23.54' (ED25519) to the list of known hosts.
Cisco Firepower Threat Defense for Azure v7.4.1 (build 132)
(admin@20.25.23.54) Password: 

Copyright 2004-2023, Cisco and/or its affiliates. All rights reserved. 
Cisco is a registered trademark of Cisco Systems, Inc. 
All other trademarks are property of their respective owners.

Cisco Firepower Extensible Operating System (FX-OS) v2.14.1 (build 112)
Cisco Firepower Threat Defense for Azure v7.4.1 (build 132)


System initialization in progress.  Please stand by.  
For system security, you must change the admin password before configuring this device.

Password must meet the following criteria: 
- At least 8 characters
- At least 1 lower case letter
- At least 1 upper case letter
- At least 1 digit
- At least 1 special character such as @#*-_+!
- No more than 2 sequentially repeated characters
- Not based on a simple character sequence or a string in password cracking dictionary

Enter new password: 
Confirm new password: 

 Password successfully changed for the admin user.

You must configure the network to continue.
Configure at least one of IPv4 or IPv6 unless managing via data interfaces.
Do you want to configure IPv4? (y/n) [y]: y
Do you want to configure IPv6? (y/n) [n]: n
Configure IPv4 via DHCP or manually? (dhcp/manual) [manual]: dhcp
If your networking information has changed, you will need to reconnect.
For HTTP Proxy configuration, run 'configure network http-proxy'

Manage the device locally? (yes/no) [yes]: yes
Configuring firewall mode to routed


Update policy deployment information
    - add device configuration
Successfully performed firstboot initial configuration steps for Firepower Device Manager for Firepower Threat Defense.

> 
```
* HTTPS Management Access to FTDv using admin credentials
    https://<management public ip>



### Cleanup

To remove the deployed infrastructure run:

```sh
terraform destroy
```

## Reference
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ftdv"></a> [ftdv](#module\_ftdv) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password. |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | The map of private IP addresses and interfaces. |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'. |
| <a name="output_subnet_cidrs"></a> [subnet\_cidrs](#output\_subnet\_cidrs) | Subnet CIDRs (sourced or created). |
| <a name="output_vnet_cidr"></a> [vnet\_cidr](#output\_vnet\_cidr) | VNET address space. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
