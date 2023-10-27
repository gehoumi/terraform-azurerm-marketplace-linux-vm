output "interfaces" {
  description = "Map of network interfaces. Keys are equal to var.interfaces `name` properties."
  value       = azurerm_network_interface.this
}
