#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg ''."
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "A container that holds related resources for an Azure solution"
}

variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources."
  default     = true
}

variable "existing_private_dns_zone" {
  type        = bool
  description = "Name of the existing private DNS zone"
  default     = false
}

variable "registration_enabled" {
  type        = bool
  description = "Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled"
  default     = false
}

###########azurerm_postgresql_flexible_server######
variable "admin_username" {
  type        = string
  default     = null
  description = "The administrator login name for the new SQL Server"
}

variable "admin_password_length" {
  type        = number
  default     = 16
  description = "Length of random password generated."
}

variable "admin_password" {
  type        = string
  description = "The password associated with the admin_username user"
  default     = null
}

variable "backup_retention_days" {
  type        = number
  default     = 7
  description = "The backup retention days for the PostgreSQL Flexible Server. Possible values are between 1 and 35 days. Defaults to 7"
}

variable "delegated_subnet_id" {
  type        = string
  default     = null
  description = "The resource ID of the subnet"
}

variable "allowed_cidrs" {
  type        = map(string)
  default     = {}
  description = "Map of authorized cidrs to connect database"
}

variable "tier" {
  description = "Tier for PostgreSQL Flexible server sku : https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage. Possible values are: GeneralPurpose, Burstable, MemoryOptimized."
  type        = string
  default     = "GeneralPurpose"
}

variable "size" {
  description = "Size for PostgreSQL Flexible server sku : https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage."
  type        = string
  default     = "D2ds_v4"
}

variable "create_mode" {
  type        = string
  description = "The creation mode. Can be used to restore or replicate existing servers. Possible values are `Default`, `Replica`, `GeoRestore`, and `PointInTimeRestore`. Defaults to `Default`"
  default     = "Default"
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  default     = false
  description = "Should geo redundant backup enabled? Defaults to false. Changing this forces a new PostgreSQL Flexible Server to be created."
}

variable "geo_backup_key_vault_key_id" {
  type        = string
  default     = null
  description = "Key-vault key id to encrypt the geo redundant backup"
}

variable "geo_backup_user_assigned_identity_id" {
  type        = string
  default     = null
  description = "User assigned identity id to encrypt the geo redundant backup"
}

variable "postgresql_version" {
  type        = string
  default     = "5.7"
  description = "The version of the PostgreSQL Flexible Server to use. Possible values are 5.7, and 8.0.21. Changing this forces a new PostgreSQL Flexible Server to be created."
}

variable "zone" {
  type        = number
  default     = null
  description = "Specifies the Availability Zone in which this PostgreSQL Flexible Server should be located. Possible values are 1, 2 and 3."
}

variable "point_in_time_restore_time_in_utc" {
  type        = string
  default     = null
  description = " The point in time to restore from creation_source_server_id when create_mode is PointInTimeRestore. Changing this forces a new PostgreSQL Flexible Server to be created."
}

variable "source_server_id" {
  type        = string
  default     = null
  description = "The resource ID of the source PostgreSQL Flexible Server to be restored. Required when create_mode is PointInTimeRestore, GeoRestore, and Replica. Changing this forces a new PostgreSQL Flexible Server to be created."
}

variable "virtual_network_id" {
  type        = string
  description = "The name of the virtual network"
  default     = ""
}

variable "key_vault_id" {
  type        = string
  default     = ""
  description = "Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret"
}

variable "private_dns" {
  type    = bool
  default = false
}

variable "main_rg_name" {
  type    = string
  default = ""
}
variable "location" {
  type        = string
  default     = ""
  description = "The Azure Region where the PostgreSQL Flexible Server should exist. Changing this forces a new PostgreSQL Flexible Server to be created."
}

variable "existing_private_dns_zone_id" {
  type    = string
  default = null
}

variable "existing_private_dns_zone_name" {
  type        = string
  default     = ""
  description = " The name of the Private DNS zone (without a terminating dot). Changing this forces a new resource to be created."
}

variable "storage_mb" {
  type        = string
  default     = "32768"
  description = "The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, and 16777216."
}

variable "database_names" {
  type        = list(string)
  default     = ["maindb"]
  description = "Specifies the name of the MySQL Database, which needs to be a valid MySQL identifier. Changing this forces a new resource to be created."
}

variable "charset" {
  type        = string
  default     = "utf8"
  description = "Specifies the Charset for the PostgreSQL Database, which needs to be a valid PostgreSQL Charset. Changing this forces a new resource to be created."
}

variable "collation" {
  type        = string
  default     = "en_US.utf8"
  description = "Specifies the Collation for the PostgreSQL Database, which needs to be a valid PostgreSQL Collation. Changing this forces a new resource to be created."
}

## Addon vritual link
variable "addon_vent_link" {
  type        = bool
  default     = false
  description = "The name of the addon vnet "
}

variable "addon_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the addon vnet resource group"
}

variable "addon_virtual_network_id" {
  type        = string
  default     = ""
  description = "The name of the addon vnet link vnet id"
}

variable "high_availability" {
  description = "Map of high availability configuration: https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-high-availability. `null` to disable high availability"
  type = object({
    standby_availability_zone = optional(number)
  })
  default = {
    standby_availability_zone = 1
  }
}

variable "enable_diagnostic" {
  type        = bool
  default     = true
  description = "Flag to control creation of diagnostic settings."
}


variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics workspace id in which logs should be retained."
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Whether metric diagnonsis should be enable in diagnostic settings for flexible Mysql."
}

variable "log_category" {
  type        = list(string)
  default     = []
  description = "Categories of logs to be recorded in diagnostic setting. Acceptable values are PostgreSQLFlexDatabaseXacts, PostgreSQLFlexQueryStoreRuntime, PostgreSQLFlexQueryStoreWaitStats ,PostgreSQLFlexSessions, PostgreSQLFlexTableStats, PostgreSQLLogs "
}

variable "log_category_group" {
  type        = list(string)
  default     = ["audit"]
  description = " Log category group for diagnostic settings."
}

variable "log_analytics_destination_type" {
  type        = string
  default     = "AzureDiagnostics"
  description = "Possible values are AzureDiagnostics and Dedicated, default to AzureDiagnostics. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Storage account id to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Eventhub Name to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG."
}

variable "active_directory_auth_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable Active Directory Authentication"
}

variable "principal_type" {
  type        = string
  default     = "Group"
  description = "Set the principal type, defaults to ServicePrincipal. The type of Azure Active Directory principal. Possible values are Group, ServicePrincipal and User. Changing this forces a new resource to be created."
}

variable "principal_name" {
  type        = string
  default     = null
  description = "The name of Azure Active Directory principal."
}

variable "maintenance_window" {
  type        = map(number)
  default     = null
  description = "Map of maintenance window configuration: https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-maintenance"
}

variable "cmk_encryption_enabled" {
  type        = bool
  default     = false
  description = "Enanle or Disable Database encryption with Customer Manage Key"
}

variable "admin_objects_ids" {
  description = "IDs of the objects that can do all operations on all keys, secrets and certificates."
  type        = list(string)
  default     = []
}

variable "expiration_date" {
  type        = string
  default     = "2024-05-22T18:29:59Z"
  description = "Expiration UTC datetime (Y-m-d'T'H:M:S'Z')"
}

variable "rotation_policy" {
  type = map(object({
    time_before_expiry   = string
    expire_after         = string
    notify_before_expiry = string
  }))
  default     = null
  description = "The rotation policy for azure key vault key"
}

variable "server_configurations" {
  description = "PostgreSQL server configurations to add."
  type        = map(string)
  default     = {}
}