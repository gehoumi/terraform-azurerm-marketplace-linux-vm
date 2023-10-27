resource "azurerm_public_ip" "this" {
  for_each = { for v in var.interfaces : v.name => v if try(v.create_public_ip, false) }

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "${each.value.name}-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null
  tags                = try(each.value.tags, var.tags)
}

data "azurerm_public_ip" "this" {
  for_each = { for v in var.interfaces : v.name => v
    if(!try(v.create_public_ip, false) && try(v.public_ip_name, null) != null)
  }

  name                = each.value.public_ip_name
  resource_group_name = try(each.value.public_ip_resource_group, null) != null ? each.value.public_ip_resource_group : var.resource_group_name
}

resource "azurerm_network_interface" "this" {
  for_each = { for k, v in var.interfaces : v.name => merge(v, { index = k }) }

  name                          = "${each.value.name}-nic"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = each.value.index == 0 ? false : var.accelerated_networking
  enable_ip_forwarding          = try(each.value.enable_ip_forwarding, each.value.index == 0 ? false : true)
  tags                          = try(each.value.tags, var.tags)

  ip_configuration {
    name                          = "primary"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = try(each.value.private_ip_address, null) != null ? "Static" : "Dynamic"
    private_ip_address            = try(each.value.private_ip_address, null)
    public_ip_address_id          = try(azurerm_public_ip.this[each.value.name].id, data.azurerm_public_ip.this[each.value.name].id, null)
  }
}

resource "azurerm_marketplace_agreement" "default" {
  count = (var.enable_plan && var.accept_marketplace_agreement) == true ? 1 : 0

  publisher = var.source_image_reference.publisher
  offer     = var.source_image_reference.offer
  plan      = var.source_image_reference.sku
}


resource "azurerm_linux_virtual_machine" "vm_linux" {

  admin_username             = var.admin_username
  location                   = var.location
  name                       = var.name
  network_interface_ids      = [for v in var.interfaces : azurerm_network_interface.this[v.name].id]
  resource_group_name        = var.resource_group_name
  size                       = var.size
  admin_password             = var.admin_password
  allow_extension_operations = var.allow_extension_operations
  availability_set_id        = var.availability_set_id
  #capacity_reservation_group_id   = var.capacity_reservation_group_id
  computer_name = coalesce(var.computer_name, var.name)
  custom_data   = var.custom_data
  #dedicated_host_group_id         = var.dedicated_host_group_id
  #dedicated_host_id               = var.dedicated_host_id
  disable_password_authentication = var.disable_password_authentication
  #edge_zone                       = var.edge_zone
  encryption_at_host_enabled = var.encryption_at_host_enabled
  #eviction_policy                 = var.eviction_policy
  extensions_time_budget = var.extensions_time_budget
  license_type           = var.license_type
  max_bid_price          = var.max_bid_price
  patch_assessment_mode  = var.patch_assessment_mode
  patch_mode             = var.patch_mode
  #platform_fault_domain  = var.platform_fault_domain
  priority           = var.priority
  provision_vm_agent = var.provision_vm_agent
  #proximity_placement_group_id = var.proximity_placement_group_id
  secure_boot_enabled = var.secure_boot_enabled
  #source_image_id              = var.source_image_id
  tags                         = var.tags
  user_data                    = var.user_data
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  vtpm_enabled                 = var.vtpm_enabled
  zone                         = var.avzone

  os_disk {
    caching                          = var.os_disk.caching
    storage_account_type             = var.os_disk.storage_account_type
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    name                             = coalesce("${var.name}-disk", var.os_disk.name)
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings == null ? [] : [
        "diff_disk_settings"
      ]

      content {
        option    = var.os_disk.diff_disk_settings.option
        placement = var.os_disk.diff_disk_settings.placement
      }
    }
  }

  dynamic "admin_ssh_key" {
    for_each = { for key in var.admin_ssh_keys : jsonencode(key) => key }

    content {
      public_key = admin_ssh_key.value.public_key
      username   = coalesce(admin_ssh_key.value.username, var.admin_username)
    }
  }
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics ? ["boot_diagnostics"] : []

    content {
      # empty block to 'use managed storage'
    }
  }

  identity {
    type         = var.identity.type
    identity_ids = var.identity.identity_ids
  }

  source_image_reference {
    offer     = var.source_image_reference.offer
    publisher = var.source_image_reference.publisher
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  dynamic "plan" {
    for_each = var.enable_plan ? ["one"] : []

    content {
      name      = var.source_image_reference.sku
      product   = var.source_image_reference.offer
      publisher = var.source_image_reference.publisher
    }
  }


  lifecycle {

    # Public keys can only be added to authorized_keys file for 'admin_username' due to a known issue in Linux provisioning agent.
    precondition {
      condition     = alltrue([for value in var.admin_ssh_keys : value.username == var.admin_username || value.username == null])
      error_message = "`username` in var.admin_ssh_keys should be the same as `admin_username` or `null`."
    }
  }
}