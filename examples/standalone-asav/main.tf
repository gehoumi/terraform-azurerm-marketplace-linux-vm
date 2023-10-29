module "asav" {
  source = "gehoumi/marketplace-linux-vm/azurerm"

  name                         = "ASAv"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-asav"
    publisher = "cisco"
    sku       = "asav-azure-byol"
    version   = "920.1.14"
  }
  custom_data = base64encode(file("${path.module}/default_initial_config.tpl"))
}


