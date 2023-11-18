# Deploy Cisco Catalyst 8000V Edge Software on Azure using Terraform module

The Cisco Catalyst 8000V Edge Software (Catalyst 8000V) is a virtual-form-factor router that delivers comprehensive SD-WAN, WAN gateway, and network services functions into virtual and cloud environments. 

By default, the Catalyst 8000V trial boots with a free 30-day Cisco DNA Advantage subscription that features 250-Mbps throughput.There will be no hourly software charges for that instance, but Azure infrastructure charges will apply. Free trials will automatically convert to paid hourly subscriptions upon expiration.
Learn more about [Cisco Catalyst 8000V Edge Software](https://www.cisco.com/c/en/us/products/routers/catalyst-8000v-edge-software/index.html).



##  How to find an image in Marketplace

You must first obtain the following IDs from : Offer, Publisher, SKU, and Version. 
This can be done from Azure CLI using the following command with the provider name, example for cisco :

```bash
# Find cisco images
az vm image list -o table --publisher cisco --offer cisco-c8000v-payg --all
  
```


## Bootstrap configuration 
This example deploys the cisco-c8000v in a new Resource Group using four interfaces, in a newly created VNet with a basic initial config file. 
For further information about providing a initial configuration file for the Cisco Catalyst 8000V instance, see [Deploying a Cisco Catalyst 8000V VM Using a Day 0](https://www.cisco.com/c/en/us/td/docs/routers/C8000V/Configuration/c8000v-installation-configuration-guide/day0-bootstrap-configuration.html#Cisco_Concept.dita_9a071ada-30b7-4014-bbb0-6630e78810a4)

## Usage

```bash
module "cisco-c8000v" {
  source = "gehoumi/marketplace-linux-vm/azurerm"

  name                         = "cisco-c8000v"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-c8000v-byol"
    publisher = "cisco"
    sku       = "17_12_01a-byol"
    version   = "17.12.0120231025"
  }
  boot_diagnostics = true
  custom_data      = base64encode(file("${path.module}/default_initial_config.tpl"))
}
```

### Deployment Steps

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
  "if-nic0" = "20.163.166.190"
  "if-nic1" = "null"
  "if-nic2" = "null"
  "if-nic3" = "null"
}
username = <sensitive>

 ```

* at this stage you have to wait couple of minutes for cisco-c8000v to bootstrap.

### Post deploy and initial configuration

Complete the Initial Configuration Using the CLI, either from Azure console port or using SSH to the Management interface. 

* Retrieve the created password:

      terraform output password:
    
* Retrieve the username:

      terraform output username:


* SSH the cisco-c8000v using the username and the password:

      ssh -o ServerAliveInterval=60 azureuser@20.163.166.190


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
| <a name="module_cisco-c8000v"></a> [cisco-c8000v](#module\_cisco-c8000v) | gehoumi/marketplace-linux-vm/azurerm | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_password"></a> [password](#output\_password) | The password to login to cisco-c8000v. |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | The map of private IP addresses and interfaces. |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'. |
| <a name="output_username"></a> [username](#output\_username) | The username to login to the cisco-c8000v |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
