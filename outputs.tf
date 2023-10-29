#output "interfaces" {
#  description = "Map of network interfaces. Keys are equal to var.interfaces `name` properties."
#  value       = azurerm_network_interface.this
#}

output "public_ip_addresses" {
  description = "The map of management IP addresses and interfaces. If `create_public_ip` was `true`, it is a public IP address, otherwise is 'null'."
  value = {
    for k, v in var.network_interfaces : k => (
      try(v.create_public_ip, false) ? (
        v.create_public_ip ? azurerm_public_ip.this[k].ip_address : "null"
      ) : "null"
    )
  }
}

output "private_ip_addresses" {
  description = "The map of private IP addresses and interfaces."
  value = {
    for k, v in var.network_interfaces : k => azurerm_network_interface.this[k].ip_configuration[0].private_ip_address
  }
}

output "password" {
  description = "Initial administrative password."
  value       = local.password
  sensitive   = true
}

output "virtual_network_id" {
  description = "The identifier of the created or sourced Virtual Network."
  value       = local.virtual_network.id
}

output "vnet_cidr" {
  description = "VNET address space."
  value       = local.virtual_network.address_space
}

output "subnet_ids" {
  description = "The identifiers of the created or sourced Subnets."
  value       = { for k, v in local.subnets : k => v.id }
}

output "subnet_cidrs" {
  description = "Subnet CIDRs (sourced or created)."
  value       = { for k, v in local.subnets : k => v.address_prefixes[0] }
}

output "network_security_group_ids" {
  description = "The identifiers of the created Network Security Groups."
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}

output "route_table_ids" {
  description = "The identifiers of the created Route Tables."
  value       = { for k, v in azurerm_route_table.this : k => v.id }
}