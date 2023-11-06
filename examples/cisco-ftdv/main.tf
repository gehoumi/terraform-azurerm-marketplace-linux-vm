module "ftdv" {
  source  = "gehoumi/marketplace-linux-vm/azurerm"
  version = "1.0.3"

  name                         = "FTDv"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-ftdv"
    publisher = "cisco"
    sku       = "ftdv-azure-byol"
    version   = "74.1.132"
  }
  boot_diagnostics = true

  # Initial configuration
  custom_data = base64encode(jsonencode({
    "AdminPassword" : module.ftdv.password,
    "Hostname" : "cisco-ftdv",
    "ManageLocally" : "Yes"
  }))

}


