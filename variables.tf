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

variable "log_analytics_workspace_name" {
  description = "The name of log analytics workspace name"
  default     = null
}

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 24
}

variable "mysqlserver_name" {
  description = "SQL server Name"
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
  })
}

variable "storage_account_name" {
  description = "The name of the storage account name"
  default     = null
}

variable "enable_threat_detection_policy" {
  description = ""
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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
