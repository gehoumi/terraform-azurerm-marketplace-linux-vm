module "ftdv" {
  source  = "gehoumi/marketplace-linux-vm/azurerm"
  version = "1.0.0"

  name                         = "FTDv"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-ftdv"
    publisher = "cisco"
    sku       = "ftdv-azure-byol"
    version   = "74.1.132"
  }
  boot_diagnostics = true
}


