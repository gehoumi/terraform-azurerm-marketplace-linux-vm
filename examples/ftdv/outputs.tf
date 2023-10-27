output "interfaces" {
  description = "Map of network interfaces. Keys are equal to var.interfaces `name` properties."
  value       = module.ftdv-vm.interfaces
}

output "password" {
  description = "Initial administrative password."
  value       = module.ftdv-vm.password
  sensitive   = true
}
