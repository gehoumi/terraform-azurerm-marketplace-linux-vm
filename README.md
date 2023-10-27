# Deploy Virtual Appliance from Azure Marketplace using Terraform module

This terraform module deploy in Azure a Linux-based image Virtual Appliance from [Azure Marketplace](https://azuremarketplace.microsoft.com/en-us/home).

For example, the Virtuals appliances like Cisco FTDv, ASAv, aci-cloud-apic-virtual, nsx-policy-manager,vmseries, ... etc can be deployed in Azure automatically after accepting the appliance image “terms of service”.

##  How to find an image in Marketplace

You must first obtain the following IDs from : Offer, Publisher, SKU, and Version. 
This can be done from Azure CLI using the following command with the provider name, example for cisco :

```bash
# Find cisco ftdv images
az vm image list -o table --publisher cisco --offer cisco-ftdv --all

# Find all cisco images
az vm image list -o table --publisher cisco --all
  
```

## Usage

Once we have this detail we can now use these elements to build out the storage_image_reference and plan blocks:

```bash

module "ftdv" {
  source = "../.."

  name                         = "FTDv"
  resource_group_name          = "mygroup_name"
  accept_marketplace_agreement = true
  source_image_reference       = {
    offer     = "cisco-ftdv"
    publisher = "cisco"
    sku       = "ftdv-azure-byol"
    version   = "74.1.132"
  }
  boot_diagnostics             = true
  interfaces                   = {
    "if-nic0" = {
      name                            = "management-subnet-0"
      address_prefixes                = ["10.100.0.0/24"]
      network_security_group          = "management-security-group"
      enable_storage_service_endpoint = true
    },
    "if-nic1" = {
      name             = "private-subnet-1"
      address_prefixes = ["10.100.1.0/24"]
    },
    "if-nic2" = {
      name                   = "private-subnet-2"
      address_prefixes       = ["10.100.2.0/24"]
      network_security_group = "outside-security-group"
    },
    "if-nic3" = {
      name             = "private-subnet-3"
      address_prefixes = ["10.100.3.0/24"]
    },
  }
}

```

## Accepting Marketplace legal terms

When deploying an image from the Marketplace, this module will create a resource to accept the End User License Agreement (EULA) for the Virtual Appliance image that is being deployed. Once the EULA is accepted one time in an Azure subscription, you should be able to deploy the same appliance again without needing to accept the terms again. But If you already accepted the same legal terms from Azure Portal or from another deployment, you can disable the resource re-creation.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.25 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.25 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.vm_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_marketplace_agreement.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/marketplace_agreement) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking"></a> [accelerated\_networking](#input\_accelerated\_networking) | Enable Azure accelerated networking (SR-IOV) for all network interfaces except the primary one. | `bool` | `true` | no |
| <a name="input_accept_marketplace_agreement"></a> [accept\_marketplace\_agreement](#input\_accept\_marketplace\_agreement) | Allows accepting the Legal Terms for a Marketplace Image, when using bring your own license.<br>You don't need set to `true` when you have already accepted the legal terms on your current subscription.<br>Check available in market place: az vm image list -o table --publisher cisco --offer cisco-Virtual Appliance --all<br>https://azuremarketplace.microsoft.com/en-us/home | `bool` | `false` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | (Optional) The Password which should be used for the local-administrator on this Virtual Machine Required when using Windows Virtual Machine. Changing this forces a new resource to be created. When an `admin_password` is specified `disable_password_authentication` must be set to `false`. One of either `admin_password` or `admin_ssh_key` must be specified. | `string` | `null` | no |
| <a name="input_admin_ssh_keys"></a> [admin\_ssh\_keys](#input\_admin\_ssh\_keys) | set(object({<br>  public\_key = "(Required) The Public Key which should be used for authentication, which needs to be at least 2048-bit and in `ssh-rsa` format. Changing this forces a new resource to be created."<br>  username   = "(Optional) The Username for which this Public SSH Key should be configured. Changing this forces a new resource to be created. The Azure VM Agent only allows creating SSH Keys at the path `/home/{admin_username}/.ssh/authorized_keys` - as such this public key will be written to the authorized keys file. If no username is provided this module will use var.admin\_username."<br>})) | <pre>set(object({<br>    public_key = string<br>    username   = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | (Optional) The admin username of the VM that will be deployed. | `string` | `"azureuser"` | no |
| <a name="input_allow_extension_operations"></a> [allow\_extension\_operations](#input\_allow\_extension\_operations) | (Optional) Should Extension Operations be allowed on this Virtual Machine? Defaults to `true`. | `bool` | `true` | no |
| <a name="input_availability_set_id"></a> [availability\_set\_id](#input\_availability\_set\_id) | The identifier of the Availability Set to use. When using this variable, set `avzone = null`. | `string` | `null` | no |
| <a name="input_avzone"></a> [avzone](#input\_avzone) | The availability zone to use, for example "1", "2", "3". Ignored if `enable_zones` is false. Conflicts with `avset_id`, in which case use `avzone = null`. | `string` | `"1"` | no |
| <a name="input_avzones"></a> [avzones](#input\_avzones) | After provider version 3.x you need to specify in which availability zone(s) you want to place IP.<br>ie: for zone-redundant with 3 availability zone in current region value will be:<pre>["1","2","3"]</pre> | `list(string)` | `[]` | no |
| <a name="input_boot_diagnostics"></a> [boot\_diagnostics](#input\_boot\_diagnostics) | (Optional) Enable or Disable boot diagnostics. | `bool` | `false` | no |
| <a name="input_bootstrap_options"></a> [bootstrap\_options](#input\_bootstrap\_options) | Bootstrap options to pass to Virtual Appliance, refer to the provider documentation. | `string` | `""` | no |
| <a name="input_computer_name"></a> [computer\_name](#input\_computer\_name) | (Optional) Specifies the Hostname which should be used for this Virtual Machine. If unspecified this defaults to the value for the `vm_name` field. If the value of the `vm_name` field is not a valid `computer_name`, then you must specify `computer_name`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | (Optional) The Base64-Encoded Custom Data which should be used for this Virtual Machine. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | (Optional) Should Password Authentication be disabled on this Virtual Machine? Defaults to `true`. Changing this forces a new resource to be created. | `bool` | `false` | no |
| <a name="input_enable_plan"></a> [enable\_plan](#input\_enable\_plan) | Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace. Can be set to `false` when using a custom image. | `bool` | `true` | no |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones. | `bool` | `true` | no |
| <a name="input_encryption_at_host_enabled"></a> [encryption\_at\_host\_enabled](#input\_encryption\_at\_host\_enabled) | (Optional) Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host? | `bool` | `false` | no |
| <a name="input_extensions_time_budget"></a> [extensions\_time\_budget](#input\_extensions\_time\_budget) | (Optional) Specifies the duration allocated for all extensions to start. The time duration should be between 15 minutes and 120 minutes (inclusive) and should be specified in ISO 8601 format. Defaults to 90 minutes (`PT1H30M`). | `string` | `"PT1H30M"` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | object({<br>  type         = "(Required) Specifies the type of Managed Service Identity that should be configured on this Linux Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."<br>  identity\_ids = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Linux Virtual Machine. This is required when `type` is set to `UserAssigned` or `SystemAssigned, UserAssigned`."<br>}) | <pre>object({<br>    type         = string<br>    identity_ids = optional(set(string))<br>  })</pre> | <pre>{<br>  "identity_ids": [],<br>  "type": "SystemAssigned"<br>}</pre> | no |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | List of the network interface specifications.<br><br>NOTICE. The ORDER in which you specify the interfaces DOES MATTER.<br>Interfaces will be attached to VM in the order you define here, therefore:<br>* The first should be the management interface, which does not participate in data filtering.<br>* The remaining ones are the dataplane interfaces.<br><br>Options for an interface object:<br>- `name`                     - (required\|string) Interface name.<br>- `subnet_id`                - (required\|string) Identifier of an existing subnet to create interface in.<br>- `create_public_ip`         - (optional\|bool) If true, create a public IP for the interface and ignore the `public_ip_address_id`. Default is false.<br>- `private_ip_address`       - (optional\|string) Static private IP to asssign to the interface. If null, dynamic one is allocated.<br>- `public_ip_name`           - (optional\|string) Name of an existing public IP to associate to the interface, used only when `create_public_ip` is `false`.<br>- `public_ip_resource_group` - (optional\|string) Name of a Resource Group that contains public IP resource to associate to the interface. When not specified defaults to `var.resource_group_name`. Used only when `create_public_ip` is `false`.<br>- `availability_zone`        - (optional\|string) Availability zone to create public IP in. If not specified, set based on `avzone` and `enable_zones`.<br>- `enable_ip_forwarding`     - (optional\|bool) If true, the network interface will not discard packets sent to an IP address other than the one assigned. If false, the network interface only accepts traffic destined to its IP address.<br>- `tags`                     - (optional\|map) Tags to assign to the interface and public IP (if created). Overrides contents of `tags` variable.<br><br>Example:<pre>[<br>  {<br>    name                 = "mgmt"<br>    subnet_id            = azurerm_subnet.my_mgmt_subnet.id<br>    public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id<br>    create_public_ip     = true<br>  },<br>  {<br>    name                = "public"<br>    subnet_id           = azurerm_subnet.my_pub_subnet.id<br>    create_public_ip    = false<br>    public_ip_name      = "fw-public-ip"<br>  },<br>]</pre> | `list(any)` | n/a | yes |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | (Optional) For Linux virtual machine specifies the BYOL Type for this Virtual Machine, possible values are `RHEL_BYOS` and `SLES_BYOS`. For Windows virtual machine specifies the type of on-premise license (also known as [Azure Hybrid Use Benefit](https://docs.microsoft.com/windows-server/get-started/azure-hybrid-benefit)) which should be used for this Virtual Machine, possible values are `None`, `Windows_Client` and `Windows_Server`. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where the Virtual Machine should exist. Changing this forces a new resource to be created. | `string` | `"eastus"` | no |
| <a name="input_max_bid_price"></a> [max\_bid\_price](#input\_max\_bid\_price) | (Optional) The maximum price you're willing to pay for this Virtual Machine, in US Dollars; which must be greater than the current spot price. If this bid price falls below the current spot price the Virtual Machine will be evicted using the `eviction_policy`. Defaults to `-1`, which means that the Virtual Machine should not be evicted for price reasons. This can only be configured when `priority` is set to `Spot`. | `number` | `-1` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of Virtual Appliance. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_network_interface_ids"></a> [network\_interface\_ids](#input\_network\_interface\_ids) | A list of Network Interface IDs which should be attached to this Virtual Machine. The first Network Interface ID in this list will be the Primary Network Interface on the Virtual Machine. Cannot be used along with `new_network_interface`. | `list(string)` | `null` | no |
| <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk) | object({<br>  caching                          = "(Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`."<br>  storage\_account\_type             = "(Required) The Type of Storage Account which should back this the Internal OS Disk. Possible values are `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS`, `StandardSSD_ZRS` and `Premium_ZRS`. Changing this forces a new resource to be created."<br>  disk\_encryption\_set\_id           = "(Optional) The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. Conflicts with `secure_vm_disk_encryption_set_id`. The Disk Encryption Set must have the `Reader` Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault"<br>  disk\_size\_gb                     = "(Optional) The Size of the Internal OS Disk in GB.if you wish to vary from the size used in the image this Virtual Machine is sourced from. If specified this must be equal to or larger than the size of the Image the Virtual Machine is based on. When creating a larger disk than exists in the image you'll need to repartition the disk to use the remaining space."<br>  name                             = "(Optional) The name which should be used for the Internal OS Disk. Changing this forces a new resource to be created."<br>  secure\_vm\_disk\_encryption\_set\_id = "(Optional) The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk when the Virtual Machine is a Confidential VM. Conflicts with `disk_encryption_set_id`. Changing this forces a new resource to be created. `secure_vm_disk_encryption_set_id` can only be specified when `security_encryption_type` is set to `DiskWithVMGuestState`."<br>  security\_encryption\_type         = "(Optional) Encryption Type when the Virtual Machine is a Confidential VM. Possible values are `VMGuestStateOnly` and `DiskWithVMGuestState`. Changing this forces a new resource to be created. `vtpm_enabled` must be set to `true` when `security_encryption_type` is specified. `encryption_at_host_enabled` cannot be set to `true` when `security_encryption_type` is set to `DiskWithVMGuestState`."<br>  write\_accelerator\_enabled        = "(Optional) Should Write Accelerator be Enabled for this OS Disk? Defaults to `false`. This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`."<br>  diff\_disk\_settings               = optional(object({<br>    option    = "(Required) Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is `Local`. Changing this forces a new resource to be created."<br>    placement = "(Optional) Specifies where to store the Ephemeral Disk. Possible values are `CacheDisk` and `ResourceDisk`. Defaults to `CacheDisk`. Changing this forces a new resource to be created."<br>  }), [])<br>}) | <pre>object({<br>    caching                          = string<br>    storage_account_type             = string<br>    disk_encryption_set_id           = optional(string)<br>    disk_size_gb                     = optional(number)<br>    name                             = optional(string)<br>    secure_vm_disk_encryption_set_id = optional(string)<br>    security_encryption_type         = optional(string)<br>    write_accelerator_enabled        = optional(bool, false)<br>    diff_disk_settings = optional(object({<br>      option    = string<br>      placement = optional(string, "CacheDisk")<br>    }), null)<br>  })</pre> | <pre>{<br>  "caching": "ReadWrite",<br>  "name": "default-disk",<br>  "storage_account_type": "StandardSSD_LRS",<br>  "write_accelerator_enabled": false<br>}</pre> | no |
| <a name="input_patch_assessment_mode"></a> [patch\_assessment\_mode](#input\_patch\_assessment\_mode) | (Optional) Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are `AutomaticByPlatform` or `ImageDefault`. Defaults to `ImageDefault`. | `string` | `"ImageDefault"` | no |
| <a name="input_patch_mode"></a> [patch\_mode](#input\_patch\_mode) | (Optional) Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are `AutomaticByPlatform` and `ImageDefault`. Defaults to `ImageDefault`. For more information on patch modes please see the [product documentation](https://docs.microsoft.com/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes). | `string` | `"ImageDefault"` | no |
| <a name="input_priority"></a> [priority](#input\_priority) | (Optional) Specifies the priority of this Virtual Machine. Possible values are `Regular` and `Spot`. Defaults to `Regular`. Changing this forces a new resource to be created. | `string` | `"Regular"` | no |
| <a name="input_provision_vm_agent"></a> [provision\_vm\_agent](#input\_provision\_vm\_agent) | (Optional) Should the Azure VM Agent be provisioned on this Virtual Machine? Defaults to `true`. Changing this forces a new resource to be created. If `provision_vm_agent` is set to `false` then `allow_extension_operations` must also be set to `false`. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group in which the Virtual Machine should be exist. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_secure_boot_enabled"></a> [secure\_boot\_enabled](#input\_secure\_boot\_enabled) | (Optional) Specifies whether secure boot should be enabled on the virtual machine. Changing this forces a new resource to be created. | `bool` | `false` | no |
| <a name="input_size"></a> [size](#input\_size) | The SKU which should be used for this Virtual Machine. Consult the cisco Deployment Guide as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | object({<br>  publisher = "(Required) Specifies the publisher of the image used to create the virtual machines. Changing this forces a new resource to be created."<br>  offer     = "(Required) Specifies the offer of the image used to create the virtual machines. Changing this forces a new resource to be created."<br>  sku       = "(Required) Specifies the SKU of the image used to create the virtual machines. Changing this forces a new resource to be created."<br>  version   = "(Required) Specifies the version of the image used to create the virtual machines. Changing this forces a new resource to be created."<br>}) | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | (Optional) The Base64-Encoded User Data which should be used for this Virtual Machine. | `string` | `null` | no |
| <a name="input_virtual_machine_scale_set_id"></a> [virtual\_machine\_scale\_set\_id](#input\_virtual\_machine\_scale\_set\_id) | (Optional) Specifies the Orchestrated Virtual Machine Scale Set that this Virtual Machine should be created within. Conflicts with `availability_set_id`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_vtpm_enabled"></a> [vtpm\_enabled](#input\_vtpm\_enabled) | (Optional) Specifies whether vTPM should be enabled on the virtual machine. Changing this forces a new resource to be created. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interfaces"></a> [interfaces](#output\_interfaces) | Map of network interfaces. Keys are equal to var.interfaces `name` properties. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
