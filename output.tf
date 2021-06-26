output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = local.location
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = element(concat(azurerm_storage_account.storeacc.*.id, [""]), 0)
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = element(concat(azurerm_storage_account.storeacc.*.name, [""]), 0)
}

output "mysql_server_id" {
  description = "The resource ID of the MySQL Server"
  value       = azurerm_mysql_server.main.id
}

output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL Server"
  value       = azurerm_mysql_server.main.fqdn
}

output "mysql_database_id" {
  description = "The resource ID of the MySQL Database"
  value       = azurerm_mysql_database.main.id
}

output "mysql_server_private_endpoint" {
  description = "id of the MySQL server Private Endpoint"
  value       = var.enable_private_endpoint ? element(concat(azurerm_private_endpoint.pep1.*.id, [""]), 0) : null
}

output "mysql_server_private_dns_zone_domain" {
  description = "DNS zone name of MySQL server Private endpoints dns name records"
  value       = var.existing_private_dns_zone == null && var.enable_private_endpoint ? element(concat(azurerm_private_dns_zone.dnszone1.*.name, [""]), 0) : var.existing_private_dns_zone
}

output "mysql_server_private_endpoint_ip" {
  description = "MySQL server private endpoint IPv4 Addresses "
  value       = var.enable_private_endpoint ? element(concat(data.azurerm_private_endpoint_connection.private-ip1.*.private_service_connection.0.private_ip_address, [""]), 0) : null
}

output "mysql_server_private_endpoint_fqdn" {
  description = "MySQL server private endpoint FQDN Addresses "
  value       = var.enable_private_endpoint ? element(concat(azurerm_private_dns_a_record.arecord1.*.fqdn, [""]), 0) : null
}
