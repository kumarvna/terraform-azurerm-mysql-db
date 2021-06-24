module "mssql-server" {
  source  = "kumarvna/mysql-db/azurerm"
  version = "1.0.0"

  # By default, this module will not create a resource group
  # proivde a name to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = false`. Location will be same as existing RG.
  create_resource_group = false
  resource_group_name   = "rg-shared-westeurope-01"
  location              = "westeurope"

  # MySQL Server and Database settings
  mysqlserver_name = "roshmysqldbsrv01"
  
  mysqlserver_settings = {
    sku_name   = "B_Gen5_2"
    storage_mb = 5120
    version    = "5.7"
    # Database name, charset and collection arguments  
    database_name = "roshydemomysqldb"
    charset       = "utf8"
    collation     = "utf8_unicode_ci"
    # Storage Profile and other optional arguments
    auto_grow_enabled                 = true
    backup_retention_days             = 7
    geo_redundant_backup_enabled      = false
    infrastructure_encryption_enabled = false
    public_network_access_enabled     = true
    ssl_enforcement_enabled           = true
    ssl_minimal_tls_version_enforced  = "TLS1_2"
  }

  # MySQL Server Parameters
  # For more information: https://docs.microsoft.com/en-us/azure/mysql/concepts-server-parameters
  mysql_configuration = {
    interactive_timeout = "600"
  }

  # AD administrator for an Azure SQL server
  # Allows you to set a user or group as the AD administrator for an Azure SQL server
  ad_admin_login_name = "firstname.lastname@example.com"

  # (Optional) To enable Azure Monitoring for Azure MySQL database
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage. 
  log_analytics_workspace_name = "loganalytics-we-sharedtest2"

  # Firewall Rules to allow azure and external clients and specific Ip address/ranges. 

  firewall_rules = {
    access-to-azure = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    },
    desktop-ip = {
      start_ip_address = "49.204.228.223"
      end_ip_address   = "49.204.228.223"
    }
  }

  # Tags for Azure Resources
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "test-user"
  }
}
