variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = true
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "subnet_id" {
  description = "The resource ID of the subnet"
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "The name of log analytics workspace name"
  default     = null
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 24
}

variable "mysqlserver_name" {
  description = "MySQL server Name"
  default     = ""
}

variable "admin_username" {
  description = "The administrator login name for the new SQL Server"
  default     = null
}

variable "admin_password" {
  description = "The password associated with the admin_username user"
  default     = null
}

variable "identity" {
  description = "If you want your SQL Server to have an managed identity. Defaults to false."
  default     = false
}

variable "mysqlserver_settings" {
  description = "MySQL server settings"
  type = object({
    sku_name                          = string
    version                           = string
    storage_mb                        = number
    auto_grow_enabled                 = optional(bool)
    backup_retention_days             = optional(number)
    geo_redundant_backup_enabled      = optional(bool)
    infrastructure_encryption_enabled = optional(bool)
    public_network_access_enabled     = optional(bool)
    ssl_enforcement_enabled           = bool
    ssl_minimal_tls_version_enforced  = optional(string)
    database_name                     = string
    charset                           = string
    collation                         = string
  })
}

variable "create_mode" {
  description = "The creation mode. Can be used to restore or replicate existing servers. Possible values are `Default`, `Replica`, `GeoRestore`, and `PointInTimeRestore`. Defaults to `Default`"
  default     = "Default"
}

variable "creation_source_server_id" {
  description = "For creation modes other than `Default`, the source server ID to use."
  default     = null
}

variable "restore_point_in_time" {
  description = "When `create_mode` is `PointInTimeRestore`, specifies the point in time to restore from `creation_source_server_id`"
  default     = null
}

variable "storage_account_name" {
  description = "The name of the storage account name"
  default     = null
}

variable "enable_threat_detection_policy" {
  description = "Threat detection policy configuration, known in the API as Server Security Alerts Policy"
  default     = false
}

variable "email_addresses_for_alerts" {
  description = "A list of email addresses which alerts should be sent to."
  type        = list(any)
  default     = []
}

variable "disabled_alerts" {
  description = "Specifies an array of alerts that are disabled. Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action."
  type        = list(any)
  default     = []
}

variable "log_retention_days" {
  description = "Specifies the number of days to keep in the Threat Detection audit logs"
  default     = "30"
}

variable "mysql_configuration" {
  description = "Sets a MySQL Configuration value on a MySQL Server"
  type        = map(string)
  default     = {}
}

variable "firewall_rules" {
  description = "Range of IP addresses to allow firewall connections."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = null
}

variable "ad_admin_login_name" {
  description = "The login name of the principal to set as the server administrator"
  default     = null
}

variable "key_vault_key_id" {
  description = "The URL to a Key Vault Key"
  default     = null
}

variable "enable_private_endpoint" {
  description = "Manages a Private Endpoint to Azure database for MySQL"
  default     = false
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  default     = ""
}

variable "existing_private_dns_zone" {
  description = "Name of the existing private DNS zone"
  default     = null
}

variable "private_subnet_address_prefix" {
  description = "The name of the subnet for private endpoints"
  default     = null
}

variable "extaudit_diag_logs" {
  description = "Database Monitoring Category details for Azure Diagnostic setting"
  default     = ["MySqlSlowLogs", "MySqlAuditLogs"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
