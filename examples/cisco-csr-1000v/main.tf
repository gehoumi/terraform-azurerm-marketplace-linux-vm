module "csr-1000v" {
  source  = "gehoumi/marketplace-linux-vm/azurerm"
  version = "1.0.3"

  name                         = "CSR-1000v"
  accept_marketplace_agreement = true
  source_image_reference = {
    offer     = "cisco-csr-1000v"
    publisher = "cisco"
    sku       = "16_9-byol"
    version   = "16.9.220181121"
  }
  custom_data = base64encode(file("${path.module}/default_initial_config.tpl"))
}


