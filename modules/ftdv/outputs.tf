output "interfaces" {
  description = "Map of network interfaces. Keys are equal to var.interfaces `name` properties."
  value       = local.interfaces
}

output "password" {
  description = "Initial administrative password."
  value       = local.password
  sensitive   = true
}