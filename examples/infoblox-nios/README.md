# Deploy Infoblox vNIOS on Azure using Terraform module

You can deploy vNIOS for Azure virtual appliances directly from Azure Marketplace. The official documentation is [here](https://docs.infoblox.com/space/vniosazure/37486729/Deploying+vNIOS+for+Azure+from+the+Marketplace) and [here](https://insights.infoblox.com/resources-deployment-guides/infoblox-deployment-guide-infoblox-vnios-for-microsoft-azure).


##  How to find an image in Marketplace

You must first obtain the following IDs from : Offer, Publisher, SKU, and Version. 
This can be done from Azure CLI using the following command  :

```bash
az vm image list -o table --publisher infoblox --offer infoblox-vm-appliances-901 --all
  
```

## Prerequisites

This example deploys infoblox-vm-appliances-901 with two interfaces on two networks.

## Parameters for Initial configuration
Available options from azure [ARM template](https://github.com/infobloxopen/infoblox-azure-templates/blob/master/main/mainTemplate.json#L471)

## Usage

```bash
module "infoblox-vm" {
  source  = "gehoumi/marketplace-linux-vm/azurerm"

  name                         = "infoblox-nios-901"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "infoblox-vm-appliances-901"
    publisher = "infoblox"
    sku       = "vgsot"
    version   = "901.49999.0"
  }
  size = "Standard_DS11_v2"
  os_disk = {
    caching                   = "ReadWrite"
    name                      = "default-disk"
    disk_size_gb              = 250
    storage_account_type      = "Premium_LRS"
    write_accelerator_enabled = false
  }

  address_space = ["10.11.0.0/16"]

  # Note: LAN1 is the default primary interface. The second interface is MGMT. 
  # Using the MGMT interface requires configuration
  # via the NIOS CLI or Grid Manager GUI after deployment
  network_interfaces = {
    "if-nic0" = {
      name                            = "private-subnet-0"
      address_prefixes                = ["10.11.0.0/24"]
      network_security_group          = "management-security-group"
      enable_storage_service_endpoint = true
      create_public_ip                = true
    },
    "if-nic1" = {
      name             = "private-subnet-1"
      address_prefixes = ["10.11.1.0/24"]
    },
  }

  boot_diagnostics = true

  # Replace the default admin password with the new password
  custom_data = base64encode("default_admin_password: ${module.infoblox-vm.password}\n")

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
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

password = <sensitive>
private_ip_addresses = {
  "if-nic0" = "10.11.0.4"
  "if-nic1" = "10.11.1.4"
}
public_ip_addresses = {
  "if-nic0" = "20.163.133.251"
  "if-nic1" = "null"
}
username = <sensitive>

 ```

* at this stage you have to wait couple of minutes for infoblox-vm-appliances-901 to bootstrap.

### Post deploy and initial configuration

Complete the Initial Configuration Using the CLI, either from Azure console port or using SSH to the Management interface. 

* Retrieve the created password:

      terraform output password:
    

* SSH the infoblox-vm-appliances-901 using admin and the password created:

      ssh admin@20.163.133.251

```bash
% terraform output password
"6_hjyjqencgmrCFo"

m % ssh admin@20.163.133.251
The authenticity of host '20.163.133.251 (20.163.133.251)' can't be established.
RSA key fingerprint is SHA256:o4uV18ifLHsdfgyujg2+4ghmDEpcvwJUy0TopM1b4.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '20.163.133.251' (RSA) to the list of known hosts.


Disconnect NOW if you have not been expressly authorized to use this system.
admin@20.163.133.251's password: 


               Infoblox NIOS Release 9.0.1-49999-eb87c18471a7 (64bit)
     Copyright (c) 1999-2023 Infoblox Inc. All Rights Reserved.

                   type 'help' for more information


Infoblox > 

```

* HTTPS Management Access using admin credentials
    https://<management public ip>

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
| <a name="module_infoblox-vm"></a> [infoblox-vm](#module\_infoblox-vm) | gehoumi/marketplace-linux-vm/azurerm | 1.0.3 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_password"></a> [password](#output\_password) | The password to login to infoblox-vm. |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | The map of private IP addresses and interfaces. |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'. |
| <a name="output_username"></a> [username](#output\_username) | The username to login to the infoblox-vm |
<!-- END_TF_DOCS -->
