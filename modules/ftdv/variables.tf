variable "location" {
  type        = string
  description = "The Azure location where the Virtual Machine should exist. Changing this forces a new resource to be created."
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which the Virtual Machine should be exist. Changing this forces a new resource to be created."
  default     = null
}

variable "name" {
  type        = string
  description = "(Required) The name of Virtual Appliance. Changing this forces a new resource to be created."
  nullable    = false
}

variable "admin_password" {
  type        = string
  default     = null
  description = "(Optional) The Password which should be used for the local-administrator on this Virtual Machine Required when using Windows Virtual Machine. Changing this forces a new resource to be created. When an `admin_password` is specified `disable_password_authentication` must be set to `false`. One of either `admin_password` or `admin_ssh_key` must be specified."
  sensitive   = true
}

variable "admin_ssh_keys" {
  type = set(object({
    public_key = string
    username   = optional(string)
  }))
  default     = []
  description = <<-EOT
  set(object({
    public_key = "(Required) The Public Key which should be used for authentication, which needs to be at least 2048-bit and in `ssh-rsa` format. Changing this forces a new resource to be created."
    username   = "(Optional) The Username for which this Public SSH Key should be configured. Changing this forces a new resource to be created. The Azure VM Agent only allows creating SSH Keys at the path `/home/{admin_username}/.ssh/authorized_keys` - as such this public key will be written to the authorized keys file. If no username is provided this module will use var.admin_username."
  }))
  EOT
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "(Optional) The admin username of the VM that will be deployed."
  nullable    = false
}


variable "enable_zones" {
  description = "If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones."
  default     = true
  type        = bool
}

variable "avzone" {
  description = "The availability zone to use, for example \"1\", \"2\", \"3\". Ignored if `enable_zones` is false. Conflicts with `avset_id`, in which case use `avzone = null`."
  default     = "1"
  type        = string
}

variable "avzones" {
  description = <<-EOF
  After provider version 3.x you need to specify in which availability zone(s) you want to place IP.
  ie: for zone-redundant with 3 availability zone in current region value will be:
  ```["1","2","3"]```
  EOF
  default     = []
  type        = list(string)
}

variable "availability_set_id" {
  description = "The identifier of the Availability Set to use. When using this variable, set `avzone = null`."
  default     = null
  type        = string
}

variable "address_space" {
  description = "The address space used by the virtual network. You can supply more than one address space."
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "secure_boot_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether secure boot should be enabled on the virtual machine. Changing this forces a new resource to be created."
}

variable "boot_diagnostics" {
  type        = bool
  default     = false
  description = "(Optional) Enable or Disable boot diagnostics."
  nullable    = false
}


variable "size" {
  description = "The SKU which should be used for this Virtual Machine. Consult the cisco Deployment Guide as only a few selected sizes are supported."
  default     = "Standard_D3_v2"
  type        = string
}


variable "enable_plan" {
  description = "Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku \"byol\", which means \"bring your own license\", still requires accepting on the Marketplace. Can be set to `false` when using a custom image."
  default     = true
  type        = bool
}

variable "accept_marketplace_agreement" {
  description = <<-EOT
  Allows accepting the Legal Terms for a Marketplace Image, when using bring your own license.
  You don't need set to `true` when you have already accepted the legal terms on your current subscription.
  Check available in market place: az vm image list -o table --publisher cisco --offer cisco-Virtual Appliance --all
  https://azuremarketplace.microsoft.com/en-us/home
  EOT
  default     = false
  type        = bool
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    offer     = "cisco-ftdv"
    publisher = "cisco"
    sku       = "ftdv-azure-byol"
    version   = "74.1.132"
  }
  description = <<-EOT
  object({
    publisher = "(Required) Specifies the publisher of the image used to create the virtual machines. Changing this forces a new resource to be created."
    offer     = "(Required) Specifies the offer of the image used to create the virtual machines. Changing this forces a new resource to be created."
    sku       = "(Required) Specifies the SKU of the image used to create the virtual machines. Changing this forces a new resource to be created."
    version   = "(Required) Specifies the version of the image used to create the virtual machines. Changing this forces a new resource to be created."
  })
  EOT
}

variable "tags" {
  type = map(string)
  default = {
    source = "terraform"
  }
  description = "A map of the tags to use on the resources that are deployed with this module."
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  default = {
    type         = "SystemAssigned"
    identity_ids = []
  }
  description = <<-EOT
  object({
    type         = "(Required) Specifies the type of Managed Service Identity that should be configured on this Linux Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
    identity_ids = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Linux Virtual Machine. This is required when `type` is set to `UserAssigned` or `SystemAssigned, UserAssigned`."
  })
  EOT
}

variable "accelerated_networking" {
  description = "Enable Azure accelerated networking (SR-IOV) for all network interfaces except the primary one."
  default     = true
  type        = bool
}

variable "bootstrap_options" {
  description = <<-EOF
  Bootstrap options to pass to Virtual Appliance, refer to the provider documentation.
  EOF
  default     = ""
  type        = string
  sensitive   = true
}


variable "computer_name" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Hostname which should be used for this Virtual Machine. If unspecified this defaults to the value for the `vm_name` field. If the value of the `vm_name` field is not a valid `computer_name`, then you must specify `computer_name`. Changing this forces a new resource to be created."
}


variable "custom_data" {
  type        = string
  default     = null
  description = "(Optional) The Base64-Encoded Custom Data which should be used for this Virtual Machine. Changing this forces a new resource to be created."

  validation {
    condition     = var.custom_data == null ? true : can(base64decode(var.custom_data))
    error_message = "The `custom_data` must be either `null` or a valid Base64-Encoded string."
  }
}

variable "user_data" {
  type        = string
  default     = null
  description = "(Optional) The Base64-Encoded User Data which should be used for this Virtual Machine."

  validation {
    condition     = var.user_data == null ? true : can(base64decode(var.user_data))
    error_message = "`user_data` must be either `null` or valid base64 encoded string."
  }
}

variable "virtual_machine_scale_set_id" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Orchestrated Virtual Machine Scale Set that this Virtual Machine should be created within. Conflicts with `availability_set_id`. Changing this forces a new resource to be created."
}

variable "encryption_at_host_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
}

variable "disable_password_authentication" {
  type        = bool
  default     = false
  description = "(Optional) Should Password Authentication be disabled on this Virtual Machine? Defaults to `true`. Changing this forces a new resource to be created."
}

variable "extensions_time_budget" {
  type        = string
  default     = "PT1H30M"
  description = "(Optional) Specifies the duration allocated for all extensions to start. The time duration should be between 15 minutes and 120 minutes (inclusive) and should be specified in ISO 8601 format. Defaults to 90 minutes (`PT1H30M`)."
}

variable "allow_extension_operations" {
  type        = bool
  default     = true
  description = "(Optional) Should Extension Operations be allowed on this Virtual Machine? Defaults to `true`."
}

variable "license_type" {
  type        = string
  default     = null
  description = "(Optional) For Linux virtual machine specifies the BYOL Type for this Virtual Machine, possible values are `RHEL_BYOS` and `SLES_BYOS`. For Windows virtual machine specifies the type of on-premise license (also known as [Azure Hybrid Use Benefit](https://docs.microsoft.com/windows-server/get-started/azure-hybrid-benefit)) which should be used for this Virtual Machine, possible values are `None`, `Windows_Client` and `Windows_Server`."
}

variable "max_bid_price" {
  type        = number
  default     = -1
  description = "(Optional) The maximum price you're willing to pay for this Virtual Machine, in US Dollars; which must be greater than the current spot price. If this bid price falls below the current spot price the Virtual Machine will be evicted using the `eviction_policy`. Defaults to `-1`, which means that the Virtual Machine should not be evicted for price reasons. This can only be configured when `priority` is set to `Spot`."
}

variable "network_interface_ids" {
  type        = list(string)
  default     = null
  description = "A list of Network Interface IDs which should be attached to this Virtual Machine. The first Network Interface ID in this list will be the Primary Network Interface on the Virtual Machine. Cannot be used along with `new_network_interface`."

  validation {
    condition     = var.network_interface_ids == null ? true : length(var.network_interface_ids) > 0
    error_message = "`network_interface_ids` must be `null` or a non-empty list."
  }
}

variable "patch_assessment_mode" {
  type        = string
  default     = "ImageDefault"
  description = "(Optional) Specifies the mode of VM Guest Patching for the Virtual Machine. Possible values are `AutomaticByPlatform` or `ImageDefault`. Defaults to `ImageDefault`."
}

variable "patch_mode" {
  type        = string
  default     = "ImageDefault"
  description = "(Optional) Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are `AutomaticByPlatform` and `ImageDefault`. Defaults to `ImageDefault`. For more information on patch modes please see the [product documentation](https://docs.microsoft.com/azure/virtual-machines/automatic-vm-guest-patching#patch-orchestration-modes)."
}

variable "priority" {
  type        = string
  default     = "Regular"
  description = "(Optional) Specifies the priority of this Virtual Machine. Possible values are `Regular` and `Spot`. Defaults to `Regular`. Changing this forces a new resource to be created."
}

variable "provision_vm_agent" {
  type        = bool
  default     = true
  description = "(Optional) Should the Azure VM Agent be provisioned on this Virtual Machine? Defaults to `true`. Changing this forces a new resource to be created. If `provision_vm_agent` is set to `false` then `allow_extension_operations` must also be set to `false`."
}

variable "vtpm_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether vTPM should be enabled on the virtual machine. Changing this forces a new resource to be created."
}

variable "os_disk" {
  type = object({
    caching                          = string
    storage_account_type             = string
    disk_encryption_set_id           = optional(string)
    disk_size_gb                     = optional(number)
    name                             = optional(string)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type         = optional(string)
    write_accelerator_enabled        = optional(bool, false)
    diff_disk_settings = optional(object({
      option    = string
      placement = optional(string, "CacheDisk")
    }), null)
  })
  default = {
    caching                   = "ReadWrite"
    name                      = "default-disk"
    storage_account_type      = "StandardSSD_LRS"
    write_accelerator_enabled = false
  }
  description = <<-EOT
  object({
    caching                          = "(Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`."
    storage_account_type             = "(Required) The Type of Storage Account which should back this the Internal OS Disk. Possible values are `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS`, `StandardSSD_ZRS` and `Premium_ZRS`. Changing this forces a new resource to be created."
    disk_encryption_set_id           = "(Optional) The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. Conflicts with `secure_vm_disk_encryption_set_id`. The Disk Encryption Set must have the `Reader` Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault"
    disk_size_gb                     = "(Optional) The Size of the Internal OS Disk in GB.if you wish to vary from the size used in the image this Virtual Machine is sourced from. If specified this must be equal to or larger than the size of the Image the Virtual Machine is based on. When creating a larger disk than exists in the image you'll need to repartition the disk to use the remaining space."
    name                             = "(Optional) The name which should be used for the Internal OS Disk. Changing this forces a new resource to be created."
    secure_vm_disk_encryption_set_id = "(Optional) The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk when the Virtual Machine is a Confidential VM. Conflicts with `disk_encryption_set_id`. Changing this forces a new resource to be created. `secure_vm_disk_encryption_set_id` can only be specified when `security_encryption_type` is set to `DiskWithVMGuestState`."
    security_encryption_type         = "(Optional) Encryption Type when the Virtual Machine is a Confidential VM. Possible values are `VMGuestStateOnly` and `DiskWithVMGuestState`. Changing this forces a new resource to be created. `vtpm_enabled` must be set to `true` when `security_encryption_type` is specified. `encryption_at_host_enabled` cannot be set to `true` when `security_encryption_type` is set to `DiskWithVMGuestState`."
    write_accelerator_enabled        = "(Optional) Should Write Accelerator be Enabled for this OS Disk? Defaults to `false`. This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`."
    diff_disk_settings               = optional(object({
      option    = "(Required) Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is `Local`. Changing this forces a new resource to be created."
      placement = "(Optional) Specifies where to store the Ephemeral Disk. Possible values are `CacheDisk` and `ResourceDisk`. Defaults to `CacheDisk`. Changing this forces a new resource to be created."
    }), [])
  })
  EOT
  nullable    = false
}


variable "network_security_groups" {
  description = <<-EOF
  Map of Network Security Groups to create.
  List of available attributes of each Network Security Group entry:
  - `name` : Name of the Network Security Group.
  - `location` : (Optional) Specifies the Azure location where to deploy the resource.
  - `rules`: (Optional) A list of objects representing a Network Security Rule. The key of each entry acts as the name of the rule and
      needs to be unique across all rules in the Network Security Group.
      List of attributes available to define a Network Security Rule.
      Notice, all port values are integers between `0` and `65535`. Port ranges can be specified as `minimum-maximum` port value, example: `21-23`:
      - `priority` : Numeric priority of the rule. The value can be between 100 and 4096 and must be unique for each rule in the collection.
      The lower the priority number, the higher the priority of the rule.
      - `direction` : The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are `Inbound` and `Outbound`.
      - `access` : Specifies whether network traffic is allowed or denied. Possible values are `Allow` and `Deny`.
      - `protocol` : Network protocol this rule applies to. Possible values include `Tcp`, `Udp`, `Icmp`, or `*` (which matches all). For supported values refer to the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule#protocol)
      - `source_port_range` : A source port or a range of ports. This can also be an `*` to match all.
      - `source_port_ranges` : A list of source ports or ranges of ports. This can be specified only if `source_port_range` was not used.
      - `destination_port_range` : A destination port or a range of ports. This can also be an `*` to match all.
      - `destination_port_ranges` : A list of destination ports or a ranges of ports. This can be specified only if `destination_port_range` was not used.
      - `source_address_prefix` : Source CIDR or IP range or `*` to match any IP. This can also be a tag. To see all available tags for a region use the following command (example for US West Central): `az network list-service-tags --location westcentralus`.
      - `source_address_prefixes` : A list of source address prefixes. Tags are not allowed. Can be specified only if `source_address_prefix` was not used.
      - `destination_address_prefix` : Destination CIDR or IP range or `*` to match any IP. Tags are allowed, see `source_address_prefix` for details.
      - `destination_address_prefixes` : A list of destination address prefixes. Tags are not allowed. Can be specified only if `destination_address_prefix` was not used.

  ```
  EOF
  default     = null
}

variable "allow_inbound_mgmt_ips" {
  description = <<-EOF
    List of IP CIDR ranges that are allowed to access management interface.
  EOF
  type        = list(string)
  default     = []
}

variable "route_tables" {
  description = <<-EOF
  Map of objects describing a Route Table.
  List of available attributes of each Route Table entry:
  - `name`: Name of a Route Table.
  - `location` : (Optional) Specifies the Azure location where to deploy the resource.
  - `routes` : (Optional) Map of routes within the Route Table.
    List of available attributes of each route entry:
    - `address_prefix` : The destination CIDR to which the route applies, such as `10.1.0.0/16`.
    - `next_hop_type` : The type of Azure hop the packet should be sent to.
      Possible values are: `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance` and `None`.
    - `next_hop_in_ip_address` : Contains the IP address packets should be forwarded to. 
      Next hop values are only allowed in routes where the next hop type is `VirtualAppliance`.

  Example:
  ```
  {
    "rt_1" = {
      name = "route_table_1"
      routes = {
        "route_1" = {
          address_prefix = "10.1.0.0/16"
          next_hop_type  = "vnetlocal"
        },
        "route_2" = {
          address_prefix = "10.2.0.0/16"
          next_hop_type  = "vnetlocal"
        },
      }
    },
    "rt_2" = {
      name = "route_table_2"
      routes = {
        "route_3" = {
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.112.0.100"
        }
      },
    },
  }
  ```
  EOF
  default     = {}
}

variable "subnets" {
  description = <<-EOF
  Map of subnet objects to create within a virtual network. If `create_subnets` is set to `false` this is just a mapping between the existing subnets and UDRs and NSGs that should be assigned to them.
  
  List of available attributes of each subnet entry:
  - `name` - Name of a subnet.
  - `address_prefixes` : The address prefix to use for the subnet. Only required when a subnet will be created.
  - `network_security_group` : The Network Security Group identifier to associate with the subnet.
  - `route_table_id` : The Route Table identifier to associate with the subnet.
  - `enable_storage_service_endpoint` : Flag that enables `Microsoft.Storage` service endpoint on a subnet. This is a suggested setting for the management interface when full bootstrapping using an Azure Storage Account is used. Defaults to `false`.
  EOF
  default = {
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


