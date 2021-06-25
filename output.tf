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

