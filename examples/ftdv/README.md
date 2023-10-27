# Example of deploying standalone Cisco FTDv Threat Defense Virtual on Azure using Terraform module

The Secure Firewall Threat Defense Virtual is integrated into the Microsoft Azure marketplace and cisco official documentation is [here](https://www.cisco.com/c/en/us/td/docs/security/firepower/quick_start/consolidated_ftdv_gsg/ftdv-gsg/m-ftdv-azure-gsg.html).

### Deployment Steps

* (optional) authenticate to AzureRM, switch to the Subscription of your choice if necessary
* initialize the Terraform module:

      terraform init

* (optional) plan you infrastructure to see what will be actually deployed:

      terraform plan

* deploy the infrastructure (you will have to confirm it with typing in `yes`):

      terraform apply

  The deployment takes couple of minutes.

* at this stage you have to wait couple of minutes for ftdv to bootstrap.

### Post deploy

Firewalls in this example are configured with password authentication. To retrieve the initial credentials run:

* for username:

      terraform output username

* for password:

      terraform output password


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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ftdv-vm"></a> [ftdv-vm](#module\_ftdv-vm) | ../../modules/ftdv | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The Azure location where the Virtual Machine should exist. Changing this forces a new resource to be created. | `string` | `"eastus"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interfaces"></a> [interfaces](#output\_interfaces) | Map of network interfaces. Keys are equal to var.interfaces `name` properties. |
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
