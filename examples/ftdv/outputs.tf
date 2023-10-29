output "public_ip_addresses" {
  description = "The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'."
  value       = module.ftdv.public_ip_addresses
}

output "private_ip_addresses" {
  description = "The map of private IP addresses and interfaces."
  value       = module.ftdv.private_ip_addresses
}

output "password" {
  description = "Initial administrative password."
  value       = module.ftdv.password
  sensitive   = true
}

output "vnet_cidr" {
  description = "VNET address space."
  value       = module.ftdv.vnet_cidr
}

output "subnet_cidrs" {
  description = "Subnet CIDRs (sourced or created)."
  value       = module.ftdv.subnet_cidrs
}
