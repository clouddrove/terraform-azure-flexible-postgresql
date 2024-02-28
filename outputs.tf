output "postgresql_flexible_server_id" {
  value       = try(azurerm_postgresql_flexible_server.main[0].id, null)
  description = "The ID of the PostgreSQL Flexible Server."
}

output "azurerm_private_dns_zone_virtual_network_link_id" {
  value       = try(azurerm_private_dns_zone_virtual_network_link.main[0].id, null)
  description = "The ID of the Private DNS Zone Virtual Network Link."
}

output "existing_private_dns_zone_virtual_network_link_id" {
  value       = try(azurerm_private_dns_zone_virtual_network_link.main2[0].id, null)
  description = "The ID of the Private DNS Zone Virtual Network Link."
}

output "azurerm_private_dns_zone_id" {
  value       = try(azurerm_private_dns_zone.main[0].id, null)
  description = "The Private DNS Zone ID."
}