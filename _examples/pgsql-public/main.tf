provider "azurerm" {
  features {}
  #Subscription ID is required to authenticate with Azure.
  subscription_id = "01110-12010122022111111c" 
}

data "azurerm_client_config" "current_client_config" {}

locals {
  name        = "app"
  environment = "test"
  label_order = ["name", "environment"]
}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "clouddrove/resource-group/azure"
  version     = "1.0.2"
  name        = local.name
  environment = local.environment
  label_order = local.label_order
  location    = "Canada Central"
}

##-----------------------------------------------------------------------------
## Log Analytics module call.
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.1.0"
  name                             = local.name
  environment                      = local.environment
  label_order                      = local.label_order
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  retention_in_days                = 90
  daily_quota_gb                   = "-1"
  internet_ingestion_enabled       = true
  internet_query_enabled           = true
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
  log_analytics_workspace_id       = module.log-analytics.workspace_id
}

##----------------------------------------------------------------------------- 
## Key Vault module call.
##-----------------------------------------------------------------------------
module "vault" {
  providers = {
    azurerm.main_sub = azurerm,
    azurerm.dns_sub  = azurerm
  }
  source  = "clouddrove/key-vault/azure"
  version = "1.2.0"

  name                        = "pgsqlvault98"
  environment                 = "test"
  label_order                 = ["name", "environment", ]
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  admin_objects_ids           = [data.azurerm_client_config.current_client_config.object_id]
  enable_rbac_authorization   = true
  enabled_for_disk_encryption = false
  #private endpoint
  enable_private_endpoint = false
  network_acls            = null
}

module "flexible-postgresql" {
  depends_on          = [module.resource_group]
  source              = "../.."
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  #**************************server configuration***************************
  postgresql_version = "16"
  admin_username     = "postgresqlusername"
  admin_password     = "ba5yatgfgfhdsv6A3ns2lu4gqzzc" # Null value will generate random password and added to tfstate file.
  tier               = "Burstable"
  size               = "B1ms"
  database_names     = ["maindb"]
  #high_availability is applicable if tier are GeneralPurpose and MemoryOptimized.
  high_availability = {
    mode                      = "ZoneRedundant"
    standby_availability_zone = 2
  }
  #Entra_id Group name or user who can log into database.
  principal_name = "Database_Admins"

  #**************************Public server*********************************
  allowed_cidrs = {
    "allowed_all_ip"      = "0.0.0.0/0"
    "allowed_specific_ip" = "11.32.16.78/32"
  }

  #**************************Logging*****************************************
  # By default diagnostic setting is enabled and logs are set AuditLogs and All_Metric. To disable logging set enable_diagnostic to false.
  log_analytics_workspace_id = module.log-analytics.workspace_id

  #**************************Encryption**************************************
  # Database encryption with costumer manage keys
  cmk_encryption_enabled = true
  key_vault_id           = module.vault.id
  admin_objects_ids      = [data.azurerm_client_config.current_client_config.object_id]
}
