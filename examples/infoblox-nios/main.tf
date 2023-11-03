module "infoblox-vm" {
  source  = "gehoumi/marketplace-linux-vm/azurerm"
  version = "1.0.3"

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


