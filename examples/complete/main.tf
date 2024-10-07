provider "azurerm" {
  features {}
  subscription_id = "000000-11111-1223-XXX-XXXXXXXXXXXX"
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
## Virtual Network module call.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "clouddrove/vnet/azure"
  version             = "1.0.4"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Subnet module call.
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "clouddrove/subnet/azure"
  version              = "1.2.1"
  name                 = local.name
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  #subnet
  subnet_names      = ["default"]
  subnet_prefixes   = ["10.0.1.0/24"]
  service_endpoints = ["Microsoft.Storage"]
  delegation = {
    flexibleServers_delegation = [
      {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    ]
  }
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
  source = "clouddrove/key-vault/azure"

  version = "1.2.0"

  name                        = "pgsqlvault498"
  environment                 = "test"
  label_order                 = ["name", "environment", ]
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  admin_objects_ids           = [data.azurerm_client_config.current_client_config.object_id]
  virtual_network_id          = module.vnet.vnet_id
  subnet_id                   = module.subnet.default_subnet_id[0]
  enable_rbac_authorization   = true
  enabled_for_disk_encryption = false
  #private endpoint
  enable_private_endpoint = false
  network_acls            = null
}

module "flexible-postgresql" {
  depends_on          = [module.resource_group, module.vnet]
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

  #**************************private server*********************************
  #(Resources to recreate when changing private to public cluster or vise-versa )
  virtual_network_id  = module.vnet.vnet_id
  private_dns         = true
  delegated_subnet_id = module.subnet.default_subnet_id[0]

  #**************************Logging*****************************************
  # By default diagnostic setting is enabled and logs are set AuditLogs and All_Metric. To disable logging set enable_diagnostic to false.
  log_analytics_workspace_id = module.log-analytics.workspace_id

  #**************************Encryption**************************************
  # Database encryption with costumer manage keys
  cmk_encryption_enabled = true
  key_vault_id           = module.vault.id
  admin_objects_ids      = [data.azurerm_client_config.current_client_config.object_id]
}
