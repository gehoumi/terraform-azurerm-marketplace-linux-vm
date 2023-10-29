module "ftdv" {
  source = "../.."

  name                         = "FTDv"
  resource_group_name          = "cloudops"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-ftdv"
    publisher = "cisco"
    sku       = "ftdv-azure-byol"
    version   = "74.1.132"
  }
  boot_diagnostics = true
}


