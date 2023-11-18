module "cisco-c8000v" {
  source = "gehoumi/marketplace-linux-vm/azurerm"

  name                         = "cisco-c8000v"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-c8000v-byol"
    publisher = "cisco"
    sku       = "17_12_01a-byol"
    version   = "17.12.0120231025"
  }
  boot_diagnostics = true
  custom_data      = base64encode(file("${path.module}/default_initial_config.tpl"))
}


