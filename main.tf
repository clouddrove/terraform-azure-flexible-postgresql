data "azurerm_client_config" "current" {}

data "azuread_group" "main" {
  count        = var.active_directory_auth_enabled != null && var.principal_name != null ? 1 : 0
  display_name = var.principal_name
}

locals {
  resource_group_name = var.resource_group_name
  location            = var.location
  tier_map = {
    "GeneralPurpose"  = "GP"
    "Burstable"       = "B"
    "MemoryOptimized" = "MO"
  }
}

##-----------------------------------------------------------------------------
## Random Password Resource.
## Will be passed as admin password of mysql server when admin password is not passed manually as variable.
##-----------------------------------------------------------------------------
resource "random_password" "main" {
  count       = var.enabled && var.admin_password == null ? 1 : 0
  length      = var.admin_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false
}

##-----------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##-----------------------------------------------------------------------------
module "labels" {
  source      = "clouddrove/labels/azure"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
  extra_tags  = var.extra_tags
}

##----------------------------------------------------------------------------- 
## Below resource will create postgresql flexible server.    
##-----------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server" "main" {
  count                             = var.enabled ? 1 : 0
  name                              = var.server_custom_name != null ? var.server_custom_name : format("%s-pgsql-flexible-server", module.labels.id)
  resource_group_name               = local.resource_group_name
  location                          = local.location
  administrator_login               = var.admin_username
  administrator_password            = var.admin_password == null ? random_password.main[0].result : var.admin_password
  backup_retention_days             = var.backup_retention_days
  delegated_subnet_id               = var.delegated_subnet_id
  private_dns_zone_id               = var.private_dns ? azurerm_private_dns_zone.main[0].id : var.existing_private_dns_zone_id
  sku_name                          = join("_", [lookup(local.tier_map, var.tier, "GeneralPurpose"), "Standard", var.size])
  create_mode                       = var.create_mode
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  point_in_time_restore_time_in_utc = var.create_mode == "PointInTimeRestore" ? var.point_in_time_restore_time_in_utc : null
  public_network_access_enabled     = var.public_network_access_enabled
  source_server_id                  = var.create_mode == "PointInTimeRestore" ? var.source_server_id : null
  storage_mb                        = var.storage_mb
  version                           = var.postgresql_version
  zone                              = var.zone
  tags                              = module.labels.tags
  dynamic "high_availability" {
    for_each = toset(var.high_availability != null && var.tier != "Burstable" ? [var.high_availability] : [])

    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = lookup(high_availability.value, "standby_availability_zone", 1)
    }
  }

  dynamic "maintenance_window" {
    for_each = toset(var.maintenance_window != null ? [var.maintenance_window] : [])
    content {
      day_of_week  = lookup(maintenance_window.value, "day_of_week", 0)
      start_hour   = lookup(maintenance_window.value, "start_hour", 0)
      start_minute = lookup(maintenance_window.value, "start_minute", 0)
    }
  }

  dynamic "authentication" {
    for_each = var.enabled && var.active_directory_auth_enabled ? [1] : [0]

    content {
      active_directory_auth_enabled = var.active_directory_auth_enabled
      tenant_id                     = data.azurerm_client_config.current.tenant_id
    }
  }

  dynamic "identity" {
    for_each = var.cmk_encryption_enabled ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.identity[0].id]
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.cmk_encryption_enabled ? [1] : []
    content {
      key_vault_key_id                     = azurerm_key_vault_key.kvkey[0].id
      primary_user_assigned_identity_id    = azurerm_user_assigned_identity.identity[0].id
      geo_backup_key_vault_key_id          = var.geo_redundant_backup_enabled ? var.geo_backup_key_vault_key_id : null
      geo_backup_user_assigned_identity_id = var.geo_redundant_backup_enabled ? var.geo_backup_user_assigned_identity_id : null

    }
  }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.main, azurerm_private_dns_zone_virtual_network_link.main2]

  lifecycle {
    ignore_changes = [high_availability.0.standby_availability_zone]
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create user assigned identity in your azure environment. 
## This user assigned identity will be created when pgsql with cmk is created.    
##-----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "identity" {
  count               = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  location            = local.location
  name                = format("%s-pgsql-mid", module.labels.id)
  resource_group_name = var.resource_group_name
}

##-----------------------------------------------------------------------------
## Below resource will provide user access on key vault based on role base access in azure environment.
## if rbac is enabled then below resource will create. 
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "rbac_keyvault_crypto_officer" {
  for_each             = toset(var.enabled && var.cmk_encryption_enabled ? var.admin_objects_ids : [])
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = each.value
}

##----------------------------------------------------------------------------- 
## Below resource will assign 'Key Vault Crypto Service Encryption User' role to user assigned identity created above. 
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "identity_assigned" {
  depends_on           = [azurerm_user_assigned_identity.identity]
  count                = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.identity[0].principal_id
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

##----------------------------------------------------------------------------- 
## Below resource will create key vault key that will be used for encryption.  
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "kvkey" {
  depends_on      = [azurerm_role_assignment.identity_assigned, azurerm_role_assignment.rbac_keyvault_crypto_officer]
  count           = var.enabled && var.cmk_encryption_enabled ? 1 : 0
  name            = format("%s-pgsql-kv-key", module.labels.id)
  expiration_date = var.expiration_date
  key_vault_id    = var.key_vault_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  dynamic "rotation_policy" {
    for_each = var.rotation_policy != null ? var.rotation_policy : {}
    content {
      automatic {
        time_before_expiry = rotation_policy.value.time_before_expiry
      }

      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry
    }
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create Firewall rules for Public server.
##-----------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server_firewall_rule" "firewall_rules" {
  for_each = var.enabled && !var.private_dns ? var.allowed_cidrs : {}

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.main[0].id
  start_ip_address = cidrhost(each.value, 0)
  end_ip_address   = cidrhost(each.value, -1)
}

##-----------------------------------------------------------------------------
## Below resource will create mysql flexible database.
##-----------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server_database" "main" {
  for_each   = var.enabled ? toset(var.database_names) : []
  name       = each.value
  server_id  = azurerm_postgresql_flexible_server.main[0].id
  charset    = var.charset
  collation  = var.collation
  depends_on = [azurerm_postgresql_flexible_server.main]
}

resource "azurerm_postgresql_flexible_server_configuration" "main" {
  for_each  = var.enabled ? var.server_configurations : {}
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main[0].id
  value     = each.value
}
##------------------------------------------------------------------------
## Private DNS for a PostgreSQL Server. - Default is "false"
##------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "main" {
  count               = var.enabled && var.private_dns ? 1 : 0
  name                = format("%s.privatelink.postgres.database.azure.com", module.labels.id)
  resource_group_name = local.resource_group_name
  tags                = module.labels.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  count                 = var.enabled && var.private_dns ? 1 : 0
  name                  = format("%s-pgsql-vnet-link", module.labels.id)
  private_dns_zone_name = azurerm_private_dns_zone.main[0].name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = local.resource_group_name
  registration_enabled  = var.registration_enabled
  tags                  = module.labels.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main2" {
  count                 = var.enabled && var.existing_private_dns_zone ? 1 : 0
  name                  = format("%s-pgsql-vnet-link", module.labels.id)
  private_dns_zone_name = var.existing_private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.main_rg_name
  registration_enabled  = var.registration_enabled
  tags                  = module.labels.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "addon_vent_link" {
  count                 = var.enabled && var.addon_vent_link ? 1 : 0
  name                  = format("%s-pgsql-vnet-link-addon", module.labels.id)
  resource_group_name   = var.addon_resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.main[0].name : var.existing_private_dns_zone
  virtual_network_id    = var.addon_virtual_network_id
  tags                  = module.labels.tags
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "main" {
  count               = var.enabled && var.active_directory_auth_enabled && var.principal_name != null ? 1 : 0
  server_name         = azurerm_postgresql_flexible_server.main[0].name
  resource_group_name = local.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = var.ad_admin_objects_id == null ? data.azuread_group.main[0].object_id : var.ad_admin_objects_id
  principal_name      = var.principal_name
  principal_type      = var.principal_type
}

resource "azurerm_monitor_diagnostic_setting" "postgresql" {
  count                          = var.enabled && var.enable_diagnostic ? 1 : 0
  name                           = format("%s-pgsql-diag-log", module.labels.id)
  target_resource_id             = azurerm_postgresql_flexible_server.main[0].id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_log" {
    for_each = length(var.log_category) > 0 ? var.log_category : var.log_category_group
    content {
      category       = length(var.log_category) > 0 ? enabled_log.value : null
      category_group = length(var.log_category) > 0 ? null : enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = metric.value
      enabled  = true
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}