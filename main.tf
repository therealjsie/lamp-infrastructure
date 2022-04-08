resource "azurerm_resource_group" "service_name" {
  name     = local.resource_group_name
  location = var.location
  tags = {
    "application" = var.service_name,
    "stage"       = var.stage_name
  }
}

resource "azurerm_kubernetes_cluster" "service_name" {
  name                             = local.aks_cluster_name
  dns_prefix                       = local.aks_cluster_name
  location                         = azurerm_resource_group.service_name.location
  resource_group_name              = azurerm_resource_group.service_name.name
  http_application_routing_enabled = true

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_database
resource "azurerm_postgresql_server" "service_name" {
  name                = local.postgres_server_name
  location            = azurerm_resource_group.service_name.location
  resource_group_name = azurerm_resource_group.service_name.name

  sku_name = "B_Gen5_1"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladmin"
  administrator_login_password = var.postgres_admin_password
  version                      = "11"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "service_name" {
  name                = local.postgres_server_name
  resource_group_name = azurerm_resource_group.service_name.name
  server_name         = azurerm_postgresql_server.service_name.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
