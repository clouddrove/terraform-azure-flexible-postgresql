output "flexible-postgresql_server_id" {
  value       = module.flexible-postgresql.postgresql_flexible_server_id
  description = "The ID of the PostgreSQL Flexible Server."
}

output "azurerm_private_dns_zone_virtual_network_link_id" {
  value       = module.flexible-postgresql.azurerm_private_dns_zone_virtual_network_link_id
  description = "The ID of the Private DNS Zone Virtual Network Link."
}


output "azurerm_private_dns_zone_id" {
  value       = module.flexible-postgresql.azurerm_private_dns_zone_id
  description = "The Private DNS Zone ID."
}



