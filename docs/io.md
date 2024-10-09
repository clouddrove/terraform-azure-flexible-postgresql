## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| active\_directory\_auth\_enabled | Set to true to enable Active Directory Authentication | `bool` | `true` | no |
| ad\_admin\_objects\_id | azurerm postgresql flexible server active directory administrator's object id | `string` | `null` | no |
| addon\_resource\_group\_name | The name of the addon vnet resource group | `string` | `""` | no |
| addon\_vent\_link | The name of the addon vnet | `bool` | `false` | no |
| addon\_virtual\_network\_id | The name of the addon vnet link vnet id | `string` | `""` | no |
| admin\_objects\_ids | IDs of the objects that can do all operations on all keys, secrets and certificates. | `list(string)` | `[]` | no |
| admin\_password | The password associated with the admin\_username user | `string` | `null` | no |
| admin\_password\_length | Length of random password generated. | `number` | `16` | no |
| admin\_username | The administrator login name for the new SQL Server | `string` | `null` | no |
| allowed\_cidrs | Map of authorized cidrs to connect database | `map(string)` | `{}` | no |
| backup\_retention\_days | The backup retention days for the PostgreSQL Flexible Server. Possible values are between 1 and 35 days. Defaults to 7 | `number` | `7` | no |
| charset | Specifies the Charset for the PostgreSQL Database, which needs to be a valid PostgreSQL Charset. Changing this forces a new resource to be created. | `string` | `"utf8"` | no |
| cmk\_encryption\_enabled | Enanle or Disable Database encryption with Customer Manage Key | `bool` | `false` | no |
| collation | Specifies the Collation for the PostgreSQL Database, which needs to be a valid PostgreSQL Collation. Changing this forces a new resource to be created. | `string` | `"en_US.utf8"` | no |
| create\_mode | The creation mode. Can be used to restore or replicate existing servers. Possible values are `Default`, `Replica`, `GeoRestore`, and `PointInTimeRestore`. Defaults to `Default` | `string` | `"Default"` | no |
| database\_names | Specifies the name of the MySQL Database, which needs to be a valid MySQL identifier. Changing this forces a new resource to be created. | `list(string)` | <pre>[<br>  "maindb"<br>]</pre> | no |
| delegated\_subnet\_id | The resource ID of the subnet | `string` | `null` | no |
| enable\_diagnostic | Flag to control creation of diagnostic settings. | `bool` | `true` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| eventhub\_authorization\_rule\_id | Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| eventhub\_name | Eventhub Name to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| existing\_private\_dns\_zone | Name of the existing private DNS zone | `bool` | `false` | no |
| existing\_private\_dns\_zone\_id | n/a | `string` | `null` | no |
| existing\_private\_dns\_zone\_name | The name of the Private DNS zone (without a terminating dot). Changing this forces a new resource to be created. | `string` | `""` | no |
| expiration\_date | Expiration UTC datetime (Y-m-d'T'H:M:S'Z') | `string` | `"2034-05-22T18:29:59Z"` | no |
| extra\_tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(string)` | `{}` | no |
| geo\_backup\_key\_vault\_key\_id | Key-vault key id to encrypt the geo redundant backup | `string` | `null` | no |
| geo\_backup\_user\_assigned\_identity\_id | User assigned identity id to encrypt the geo redundant backup | `string` | `null` | no |
| geo\_redundant\_backup\_enabled | Should geo redundant backup enabled? Defaults to false. Changing this forces a new PostgreSQL Flexible Server to be created. | `bool` | `false` | no |
| high\_availability | Map of high availability configuration: https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-high-availability. `null` to disable high availability | <pre>object({<br>    standby_availability_zone = optional(number)<br>  })</pre> | <pre>{<br>  "standby_availability_zone": 1<br>}</pre> | no |
| key\_vault\_id | Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret | `string` | `""` | no |
| label\_order | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| location | The Azure Region where the PostgreSQL Flexible Server should exist. Changing this forces a new PostgreSQL Flexible Server to be created. | `string` | `""` | no |
| log\_analytics\_destination\_type | Possible values are AzureDiagnostics and Dedicated, default to AzureDiagnostics. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table. | `string` | `"AzureDiagnostics"` | no |
| log\_analytics\_workspace\_id | Log Analytics workspace id in which logs should be retained. | `string` | `null` | no |
| log\_category | Categories of logs to be recorded in diagnostic setting. Acceptable values are PostgreSQLFlexDatabaseXacts, PostgreSQLFlexQueryStoreRuntime, PostgreSQLFlexQueryStoreWaitStats ,PostgreSQLFlexSessions, PostgreSQLFlexTableStats, PostgreSQLLogs | `list(string)` | `[]` | no |
| log\_category\_group | Log category group for diagnostic settings. | `list(string)` | <pre>[<br>  "audit"<br>]</pre> | no |
| main\_rg\_name | n/a | `string` | `""` | no |
| maintenance\_window | Map of maintenance window configuration: https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-maintenance | `map(number)` | `null` | no |
| managedby | ManagedBy, eg ''. | `string` | `""` | no |
| metric\_enabled | Whether metric diagnonsis should be enable in diagnostic settings for flexible Mysql. | `bool` | `true` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| point\_in\_time\_restore\_time\_in\_utc | The point in time to restore from creation\_source\_server\_id when create\_mode is PointInTimeRestore. Changing this forces a new PostgreSQL Flexible Server to be created. | `string` | `null` | no |
| postgresql\_version | The version of the PostgreSQL Flexible Server to use. Possible values are 5.7, and 8.0.21. Changing this forces a new PostgreSQL Flexible Server to be created. | `string` | `"5.7"` | no |
| principal\_name | The name of Azure Active Directory principal. | `string` | `null` | no |
| principal\_type | Set the principal type, defaults to ServicePrincipal. The type of Azure Active Directory principal. Possible values are Group, ServicePrincipal and User. Changing this forces a new resource to be created. | `string` | `"Group"` | no |
| private\_dns | n/a | `bool` | `false` | no |
| public\_network\_access\_enabled | Enable public network access for the PostgreSQL Flexible Server | `bool` | `false` | no |
| registration\_enabled | Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled | `bool` | `false` | no |
| repository | Terraform current module repo | `string` | `""` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution | `string` | `""` | no |
| rotation\_policy | The rotation policy for azure key vault key | <pre>map(object({<br>    time_before_expiry   = string<br>    expire_after         = string<br>    notify_before_expiry = string<br>  }))</pre> | `null` | no |
| server\_configurations | PostgreSQL server configurations to add. | `map(string)` | `{}` | no |
| size | Size for PostgreSQL Flexible server sku : https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage. | `string` | `"D2ds_v4"` | no |
| source\_server\_id | The resource ID of the source PostgreSQL Flexible Server to be restored. Required when create\_mode is PointInTimeRestore, GeoRestore, and Replica. Changing this forces a new PostgreSQL Flexible Server to be created. | `string` | `null` | no |
| storage\_account\_id | Storage account id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| storage\_mb | The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, and 16777216. | `string` | `"32768"` | no |
| tier | Tier for PostgreSQL Flexible server sku : https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage. Possible values are: GeneralPurpose, Burstable, MemoryOptimized. | `string` | `"GeneralPurpose"` | no |
| virtual\_network\_id | The name of the virtual network | `string` | `""` | no |
| zone | Specifies the Availability Zone in which this PostgreSQL Flexible Server should be located. Possible values are 1, 2 and 3. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_private\_dns\_zone\_id | The Private DNS Zone ID. |
| azurerm\_private\_dns\_zone\_virtual\_network\_link\_id | The ID of the Private DNS Zone Virtual Network Link. |
| existing\_private\_dns\_zone\_virtual\_network\_link\_id | The ID of the Private DNS Zone Virtual Network Link. |
| postgresql\_flexible\_server\_id | The ID of the PostgreSQL Flexible Server. |

