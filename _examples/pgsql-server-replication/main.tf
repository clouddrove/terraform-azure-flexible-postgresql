provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = ""
  version = "1.0.0"

  name        = "app-postgresqll2"
  environment = "test2"
  label_order = ["name", "environment"]
  location    = "Canada Central"
}

module "vnet" {
  source              = ""
  version             = "1.0.0"
  name                = "app"
  environment         = "test2"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
  enable_ddos_pp      = false
}

module "subnet" {
  source               = ""
  version              = "1.0.0"
  name                 = "app"
  environment          = "test2"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet.vnet_name)

  #subnet
  default_name_subnet = true
  subnet_names        = ["default"]
  subnet_prefixes     = ["10.0.1.0/24"]
  service_endpoints   = ["Microsoft.Storage"]
  delegation = {
    flexibleServers_delegation = [
      {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    ]
  }
}

#existing resource group where dns zone created
data "azurerm_resource_group" "main" {
  name = "app-postgresql-test-rg"
}

data "azurerm_private_dns_zone" "main" {
  depends_on          = [data.azurerm_resource_group.main]
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.main.name
}

module "flexible-postgresql" {
  depends_on                     = [module.resource_group, module.vnet, data.azurerm_resource_group.main]
  source                         = "../.."
  name                           = "app"
  environment                    = "test2"
  label_order                    = ["name", "environment"]
  main_rg_name                   = data.azurerm_resource_group.main.name
  resource_group_name            = module.resource_group.resource_group_name
  location                       = module.resource_group.resource_group_location
  virtual_network_id             = module.vnet.vnet_id[0]
  delegated_subnet_id            = module.subnet.default_subnet_id[0]
  postgresql_version             = "12"
  zone                           = "1"
  admin_username                 = "postgresqlusern"
  admin_password                 = "ba5yatgfgfhdsvvc6A3ns2lu4gqzzc"
  tier                           = "Burstable"
  size                           = "B1ms"
  database_names                 = ["maindb"]
  charset                        = "utf8"
  collation                      = "en_US.utf8"
  existing_private_dns_zone      = true
  existing_private_dns_zone_id   = data.azurerm_private_dns_zone.main.id
  existing_private_dns_zone_name = data.azurerm_private_dns_zone.main.name
}
