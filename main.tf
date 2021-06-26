#------------------------------------------------------------
# Local configuration - Default (required). 
#------------------------------------------------------------

locals {
  resource_group_name                = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location                           = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  if_threat_detection_policy_enabled = var.enable_threat_detection_policy ? [{}] : []
  mysqlserver_settings = defaults(var.mysqlserver_settings, {
    charset   = "utf8"
    collation = "utf8_unicode_ci"
  })
}

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
}

#---------------------------------------------------------
# Storage Account to keep Audit logs - Default is "false"
#----------------------------------------------------------

resource "random_string" "str" {
  count   = var.enable_threat_detection_policy ? 1 : 0
  length  = 6
  special = false
  upper   = false
  keepers = {
    name = var.storage_account_name
  }
}

resource "azurerm_storage_account" "storeacc" {
  count                     = var.enable_threat_detection_policy ? 1 : 0
  name                      = var.storage_account_name == null ? "stsqlauditlogs${element(concat(random_string.str.*.result, [""]), 0)}" : substr(var.storage_account_name, 0, 24)
  resource_group_name       = local.resource_group_name
  location                  = local.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = merge({ "Name" = format("%s", "stsqlauditlogs") }, var.tags, )
}

resource "random_password" "main" {
  count       = var.admin_password == null ? 1 : 0
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    administrator_login_password = var.mysqlserver_name
  }
}

#----------------------------------------------------------------
# Adding  MySQL Server creation and settings - Default is "True"
#-----------------------------------------------------------------
resource "azurerm_mysql_server" "main" {
  name                              = format("%s", var.mysqlserver_name)
  resource_group_name               = local.resource_group_name
  location                          = local.location
  administrator_login               = var.admin_username == null ? "sqladmin" : var.admin_username
  administrator_login_password      = var.admin_password == null ? random_password.main.0.result : var.admin_password
  sku_name                          = var.mysqlserver_settings.sku_name
  storage_mb                        = var.mysqlserver_settings.storage_mb
  version                           = var.mysqlserver_settings.version
  auto_grow_enabled                 = var.mysqlserver_settings.auto_grow_enabled
  backup_retention_days             = var.mysqlserver_settings.backup_retention_days
  geo_redundant_backup_enabled      = var.mysqlserver_settings.geo_redundant_backup_enabled
  infrastructure_encryption_enabled = var.mysqlserver_settings.infrastructure_encryption_enabled
  public_network_access_enabled     = var.mysqlserver_settings.public_network_access_enabled
  ssl_enforcement_enabled           = var.mysqlserver_settings.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = var.mysqlserver_settings.ssl_minimal_tls_version_enforced
  create_mode                       = var.create_mode
  creation_source_server_id         = var.create_mode != "Default" ? var.creation_source_server_id : null
  restore_point_in_time             = var.create_mode == "PointInTimeRestore" ? var.restore_point_in_time : null
  tags                              = merge({ "Name" = format("%s", var.mysqlserver_name) }, var.tags, )

  dynamic "identity" {
    for_each = var.identity == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }

  dynamic "threat_detection_policy" {
    for_each = var.enable_threat_detection_policy == true ? [1] : []
    content {
      enabled                    = var.enable_threat_detection_policy
      disabled_alerts            = var.disabled_alerts
      email_account_admins       = var.email_addresses_for_alerts != null ? true : false
      email_addresses            = var.email_addresses_for_alerts
      retention_days             = var.log_retention_days
      storage_account_access_key = azurerm_storage_account.storeacc.0.primary_access_key
      storage_endpoint           = azurerm_storage_account.storeacc.0.primary_blob_endpoint
    }
  }
}

#------------------------------------------------------------
# Adding  MySQL Server Database - Default is "true"
#------------------------------------------------------------
resource "azurerm_mysql_database" "main" {
  name                = var.mysqlserver_settings.database_name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_server.main.name
  charset             = var.mysqlserver_settings.charset
  collation           = var.mysqlserver_settings.collation
}

#------------------------------------------------------------
# Adding  MySQL Server Parameters - Default is "false"
#------------------------------------------------------------
resource "azurerm_mysql_configuration" "main" {
  for_each            = var.mysql_configuration != null ? { for k, v in var.mysql_configuration : k => v if v != null } : {}
  name                = each.key
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_server.main.name
  value               = each.value
}

#------------------------------------------------------------
# Adding Firewall rules for MySQL Server - Default is "false"
#------------------------------------------------------------
resource "azurerm_mysql_firewall_rule" "main" {
  for_each            = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}
  name                = format("%s", each.key)
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_server.main.name
  start_ip_address    = each.value["start_ip_address"]
  end_ip_address      = each.value["end_ip_address"]
}

#----------------------------------------------------------
# Adding AD Admin to MySQL Server - Default is "false"
#----------------------------------------------------------
resource "azurerm_mysql_active_directory_administrator" "example" {
  count               = var.ad_admin_login_name != null ? 1 : 0
  server_name         = azurerm_mysql_server.main.name
  resource_group_name = local.resource_group_name
  login               = var.ad_admin_login_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

#------------------------------------------------------------------------
# Manages a Customer Managed Key for a MySQL Server. - Default is "false"
#------------------------------------------------------------------------
resource "azurerm_mysql_server_key" "example" {
  count            = var.key_vault_key_id != null ? 1 : 0
  server_id        = azurerm_mysql_server.main.id
  key_vault_key_id = var.key_vault_key_id
}

#--------------------------------------------------------------------------------
# Allowing traffic between an Azure SQL server and a subnet - Default is "false"
#--------------------------------------------------------------------------------
resource "azurerm_mysql_virtual_network_rule" "main" {
  count               = var.subnet_id != null ? 1 : 0
  name                = format("%s-vnet-rule", var.mysqlserver_name)
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_server.main.name
  subnet_id           = var.subnet_id
}

#---------------------------------------------------------
# Private Link for SQL Server - Default is "false" 
#---------------------------------------------------------
data "azurerm_virtual_network" "vnet01" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "snet-ep" {
  count                                          = var.enable_private_endpoint ? 1 : 0
  name                                           = "snet-endpoint-shared-${local.location}"
  resource_group_name                            = local.resource_group_name
  virtual_network_name                           = data.azurerm_virtual_network.vnet01.0.name
  address_prefixes                               = var.private_subnet_address_prefix
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "pep1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-private-endpoint", var.mysqlserver_name)
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.snet-ep.0.id
  tags                = merge({ "Name" = format("%s-private-endpoint", var.mysqlserver_name) }, var.tags, )

  private_service_connection {
    name                           = "sqldbprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mysql_server.main.id
    subresource_names              = ["mysqlServer"]
  }
}

data "azurerm_private_endpoint_connection" "private-ip1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep1.0.name
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_mysql_server.main]
}

resource "azurerm_private_dns_zone" "dnszone1" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = local.resource_group_name
  tags                = merge({ "Name" = format("%s", "MySQL-Private-DNS-Zone") }, var.tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "vent-link1" {
  count                 = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dnszone1.0.name
  virtual_network_id    = data.azurerm_virtual_network.vnet01.0.id
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, var.tags, )
}

resource "azurerm_private_dns_a_record" "arecord1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_mysql_server.main.name
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1.0.name : var.existing_private_dns_zone
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip1.0.private_service_connection.0.private_ip_address]
}

#------------------------------------------------------------------
# azurerm monitoring diagnostics  - Default is "false" 
#------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "extaudit" {
  count                      = var.log_analytics_workspace_name != null ? 1 : 0
  name                       = lower("extaudit-${var.mysqlserver_name}-diag")
  target_resource_id         = azurerm_mysql_server.main.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logws.0.id
  storage_account_id         = var.enable_threat_detection_policy ? azurerm_storage_account.storeacc.0.id : null

  dynamic "log" {
    for_each = var.extaudit_diag_logs
    content {
      category = log.value
      enabled  = true
      retention_policy {
        enabled = false
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [log, metric]
  }
}
