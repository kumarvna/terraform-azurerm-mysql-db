output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = module.mysql-db.resource_group_name
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = module.mysql-db.resource_group_location
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.mysql-db.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.mysql-db.storage_account_name
}

output "mysql_server_id" {
  description = "The resource ID of the MySQL Server"
  value       = module.mysql-db.mysql_server_id
}

output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL Server"
  value       = module.mysql-db.mysql_server_fqdn
}

output "mysql_database_id" {
  description = "The resource ID of the MySQL Database"
  value       = module.mysql-db.mysql_database_id
}
