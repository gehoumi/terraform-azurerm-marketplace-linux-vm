# Generate a random password 
resource "random_password" "this" {
  count            = var.admin_password == null ? 1 : 0
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  special          = true
  override_special = "_%@"
}

# Resource group to hold all the resources.
resource "azurerm_resource_group" "this" {
  count    = var.resource_group_name == null ? 1 : 0
  name     = "${var.name}-group-name"
  location = var.location
}

# Obtain Public IP address of code deployment machine
data "http" "this" {
  url = "https://ifconfig.me/ip"
}

locals {
  password            = coalesce(var.admin_password, try(random_password.this[0].result, null))
  resource_group_name = coalesce(var.resource_group_name, try(azurerm_resource_group.this[0], null))
}

# Virtual Network and its Network Security Group 
module "vnet" {
  source = "../vnet"

  name                    = "vnet-vm"
  location                = var.location
  resource_group_name     = local.resource_group_name
  address_space           = var.address_space
  network_security_groups = var.network_security_groups == null ? local.network_security_groups : var.network_security_groups
  route_tables            = {}
  subnets                 = var.subnets
}

locals {
  network_security_groups = {
    "management-security-group" = {
      name     = "management_network_security_group"
      location = "East US"
      rules = {
        "management-rules" = {
          access                     = "Allow"
          direction                  = "Inbound"
          priority                   = 100
          protocol                   = "Tcp"
          source_port_range          = "*"
          source_address_prefixes    = concat(try(var.allow_inbound_mgmt_ips, []), try([data.http.this.response_body], []))
          destination_address_prefix = "*"
          destination_port_ranges    = ["22", "443"]
        }
      }
    },
    "outside-security-group" = {
      name     = "outside_network_security_group"
      location = "East US"
      rules = {
        "vm-outside-rules" = {
          access                     = "Allow"
          direction                  = "Inbound"
          priority                   = 100
          protocol                   = "*" # both TCP and UDP
          source_port_range          = "*"
          source_address_prefix      = "*"
          destination_port_range     = "443"
          destination_address_prefix = "*"
        }
      }
    }

  }
}

# Deploy the Virtual Appliance
module "ftdv" {
  source = "../.."

  location                     = var.location
  resource_group_name          = local.resource_group_name
  name                         = var.name
  admin_username               = var.admin_username
  admin_password               = local.password
  accept_marketplace_agreement = true
  source_image_reference       = var.source_image_reference
  boot_diagnostics             = true
  interfaces                   = local.interfaces
}

locals {
  interfaces = [
    {
      name             = "${var.name}-if-nic0"
      subnet_id        = lookup(module.vnet.subnet_ids, "if-nic0", null)
      create_public_ip = true
    },
    {
      name      = "${var.name}-if-nic1"
      subnet_id = lookup(module.vnet.subnet_ids, "if-nic1", null)
    },
    {
      name      = "${var.name}-if-nic2"
      subnet_id = lookup(module.vnet.subnet_ids, "if-nic2", null)
    },
    {
      name      = "${var.name}-if-nic3"
      subnet_id = lookup(module.vnet.subnet_ids, "if-nic3", null)
    }
  ]
}
