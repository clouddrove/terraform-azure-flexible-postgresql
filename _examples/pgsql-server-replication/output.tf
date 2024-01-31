output "flexible-postgresql_server_id" {
  value       = module.flexible-postgresql.postgresql_flexible_server_id
  description = "The ID of the PostgreSQL Flexible Server."
}
output "azurerm_private_dns_zone_virtual_network_link2_id" {
  value       = module.flexible-postgresql.existing_private_dns_zone_virtual_network_link_id
  description = "The ID of the Private DNS Zone Virtual Network Link."
}
output "azurerm_flexible-postgresql_server_configuration_id" {
  value       = module.flexible-postgresql.azurerm_postgresql_flexible_server_configuration_id
  description = "The ID of the PostgreSQL Flexible Server Configuration."
}





