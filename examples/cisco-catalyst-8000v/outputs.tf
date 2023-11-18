output "public_ip_addresses" {
  description = "The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'."
  value       = module.cisco-c8000v.public_ip_addresses
}

output "private_ip_addresses" {
  description = "The map of private IP addresses and interfaces."
  value       = module.cisco-c8000v.private_ip_addresses
}

output "password" {
  description = "The password to login to cisco-c8000v."
  value       = module.cisco-c8000v.password
  sensitive   = true
}

output "username" {
  description = "The username to login to the cisco-c8000v"
  value       = module.cisco-c8000v.username
  sensitive   = true
}
