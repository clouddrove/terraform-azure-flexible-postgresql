provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current_client_config" {}

module "flexible-postgresql" {
  source              = "../.."
  name                = "app"
  resource_group_name = "test"
  location            = "Canada Central"

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
  virtual_network_id  = ""
  private_dns         = false
  delegated_subnet_id = null

  #**************************Logging*****************************************
  # By default diagnostic setting is enabled and logs are set AuditLogs and All_Metric. To disable logging set enable_diagnostic to false.
  enable_diagnostic          = false
  log_analytics_workspace_id = "/subscription/***************"

  #**************************Encryption**************************************
  # Database encryption with costumer manage keys
  cmk_encryption_enabled = false
  key_vault_id           = "/subscription/***************"
  admin_objects_ids      = [data.azurerm_client_config.current_client_config.object_id]
}
