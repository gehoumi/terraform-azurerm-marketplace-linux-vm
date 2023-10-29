output "public_ip_addresses" {
  description = "The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'."
  value       = module.asav.public_ip_addresses
}

output "private_ip_addresses" {
  description = "The map of private IP addresses and interfaces."
  value       = module.asav.private_ip_addresses
}

output "password" {
  description = "The password to login to ASAv."
  value       = module.asav.password
  sensitive   = true
}

output "username" {
  description = "The username to login to the ASAv"
  value       = module.asav.username
  sensitive   = true
}
