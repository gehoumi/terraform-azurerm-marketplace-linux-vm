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

## Parameters for Initial configuration
Available options from azure [ARM template](https://github.com/CiscoDevNet/cisco-ftdv/blob/master/deployment-templates/azure/CiscoSecureFirewallVirtual-7.3.0/ftdv/README.md#parameters-for-the-azure-arm-template)

```bash
customData: The field to provide Day 0 configuration to the CSF-TDv. By default it has 3 key-value pairs to configure 'admin' user password, the CSF-MCv hostname and whether to use CSF-MCv or CSF-DM for management.
'ManageLocally : yes' - will configure the CSF-DM to be used as CSF-TDv manager.
e.g. {"AdminPassword": "Password@2023", "Hostname": "cisco", "ManageLocally": "Yes"}
You can configure the CSF-MCv as CSF-TDv manager and also give the inputs for fields required to configure the same on CSF-MCv.
e.g. {"AdminPassword": "Password@2023", "Hostname": "cisco", "ManageLocally": "No", "FmcIp": "", "FmcRegKey": "", "FmcNatId": "" }

```


## Usage

```bash
module "ftdv" {
  source = "gehoumi/marketplace-linux-vm/azurerm"

  name                         = "FTDv"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-ftdv"
    publisher = "cisco"
    sku       = "ftdv-azure-byol"
    version   = "77.0.16"
  }
  boot_diagnostics = true

  # Initial configuration
  custom_data = base64encode(jsonencode({
  "AdminPassword": module.ftdv.password,
  "Hostname": "cisco-ftdv",
  "ManageLocally": "Yes"
}))

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

```bash

      Apply complete! Resources: 21 added, 0 changed, 0 destroyed.

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
```

* at this stage you have to wait couple of minutes for ftdv to bootstrap.

### Post deploy and initial configuration

Complete the Threat Defense configuration using the CLI (from Azure console port or using SSH) or using HTTPS to the Management interface Public IP. 
The module creates a password used to login the device.

* Retrieve the created password:

      terraform output password


* SSH the FTDv using cisco default username `admin` and the created password :

      ssh admin@<management public ip>
      ssh admin@20.25.23.54

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

> 
```

* HTTPS Management Access to FTDv using admin credentials:

      https://<management public ip>
      https://20.25.23.54



### Cleanup

To remove the deployed infrastructure run:

```sh
terraform destroy
```

## Reference
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ftdv"></a> [ftdv](#module\_ftdv) | gehoumi/marketplace-linux-vm/azurerm | 1.0.6 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_password"></a> [password](#output\_password) | The admin password. |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | The map of private IP addresses and interfaces. |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'. |
| <a name="output_subnet_cidrs"></a> [subnet\_cidrs](#output\_subnet\_cidrs) | Subnet CIDRs (sourced or created). |
<!-- END_TF_DOCS -->
