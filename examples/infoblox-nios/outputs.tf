output "public_ip_addresses" {
  description = "The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'."
  value       = module.infoblox-vm.public_ip_addresses
}

output "private_ip_addresses" {
  description = "The map of private IP addresses and interfaces."
  value       = module.infoblox-vm.private_ip_addresses
}

output "password" {
  description = "The password to login to infoblox-vm."
  value       = module.infoblox-vm.password
  sensitive   = true
}

output "username" {
  description = "The username to login to the infoblox-vm"
  value       = module.infoblox-vm.username
  sensitive   = true
}
