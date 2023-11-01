# Deploy Cisco CSR 1000v on Azure using Terraform module

The Cisco CSR 1000v is integrated into the Microsoft Azure marketplace and cisco official documentation is [here](https://www.cisco.com/c/en/us/td/docs/routers/csr1000/software/azu/b_csr1000config-azure/b_csr1000config-azure_chapter_01011.html).


##  How to find an image in Marketplace

You must first obtain the following IDs from : Offer, Publisher, SKU, and Version. 
This can be done from Azure CLI using the following command with the provider name, example for cisco :

```bash
# Find cisco csr-1000v images
az vm image list -o table --publisher cisco --offer cisco-csr-1000v --all
  
```

## Prerequisites

This example deploys the csr-1000v with four interfaces on four networks.

## Usage

```bash
module "csr-1000v" {
  source = "gehoumi/marketplace-linux-vm/azurerm"

  name                         = "CSR-1000v"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-csr-1000v"
    publisher = "cisco"
    sku       = "16_9-byol"
    version   = "16.9.220181121"
  }
  custom_data = base64encode(file("${path.module}/default_initial_config.tpl"))
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
  "if-nic0" = "20.185.19.145"
  "if-nic1" = "null"
  "if-nic2" = "null"
  "if-nic3" = "null"
}
username = <sensitive>

 ```

* at this stage you have to wait couple of minutes for csr-1000v to bootstrap.

### Post deploy and initial configuration

Complete the Initial Configuration Using the CLI, either from Azure console port or using SSH to the Management interface. 

* Retrieve the created password:

      terraform output password:
    
* Retrieve the deafult username:

      terraform output username:


* SSH the csr-1000v using the username and the password:

      ssh -o KexAlgorithms=diffie-hellman-group14-sha1 azureuser@20.185.19.145


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
| <a name="module_csr-1000v"></a> [csr-1000v](#module\_csr-1000v) | gehoumi/marketplace-linux-vm/azurerm | 1.0.2 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_password"></a> [password](#output\_password) | The password to login to csr-1000v. |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | The map of private IP addresses and interfaces. |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'. |
| <a name="output_username"></a> [username](#output\_username) | The username to login to the csr-1000v |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
