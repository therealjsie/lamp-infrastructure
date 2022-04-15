# Ref.: https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/azurecaf_name
resource "azurecaf_name" "postgresql_server" {
  name          = var.service_name
  suffixes      = [var.stage_name]
  resource_type = "azurerm_postgresql_server"
  clean_input   = true
}

resource "azurecaf_name" "postgresql_database" {
  name          = var.service_name
  resource_type = "azurerm_postgresql_database"
  clean_input   = true
}

resource "random_password" "postgres_admin" {
  length           = 16
  special          = true
  override_special = "!#$%*()-_=+[]{}:?"
}

resource "random_password" "database" {
  length           = 16
  special          = true
  override_special = "!#$%*()-_=+[]{}:?"
}

# Ref.: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_database
resource "azurerm_postgresql_server" "service_name" {
  name                = azurecaf_name.postgresql_server.result
  location            = azurerm_resource_group.service_name.location
  resource_group_name = azurerm_resource_group.service_name.name

  sku_name = "B_Gen5_1"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.postgres_admin_user
  administrator_login_password = random_password.postgres_admin.result
  version                      = "11"
  ssl_enforcement_enabled      = true

  tags = {
    "application" = var.service_name,
    "stage"       = var.stage_name
  }
}

# This firewall rule is necessary to allow Terraform Cloud to configure the Postgres instance. This configuration is subject for debate.
# Moving database configuration out of Terraform and into an Azure-internal service seems sensible.
# Ref.: https://www.terraform.io/cloud-docs/run/run-environment#network-access-to-vcs-and-infrastructure-providers
resource "azurerm_postgresql_firewall_rule" "public_access" {
  name                = "public_access"
  resource_group_name = azurerm_resource_group.service_name.name
  server_name         = azurerm_postgresql_server.service_name.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_postgresql_database" "service_name" {
  name                = azurecaf_name.postgresql_database.result
  resource_group_name = azurerm_resource_group.service_name.name
  server_name         = azurerm_postgresql_server.service_name.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

#Ref.: https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/
resource "postgresql_role" "service_name" {
  name        = local.postgres_user_name
  password    = random_password.database.result
  login       = true
  create_role = true
  roles       = []
  search_path = []
  # Added because there is an issue when destroying the infrastructure.
  # Ref: https://github.com/hashicorp/terraform-provider-postgresql/issues/36#issuecomment-387654085
  skip_reassign_owned = true

  depends_on = [azurerm_postgresql_database.service_name, azurerm_postgresql_firewall_rule.public_access]
}

# Ref.: https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/postgresql_grant
resource "postgresql_grant" "revoke_public" {
  database    = azurecaf_name.postgresql_database.result
  role        = "public"
  schema      = "public"
  object_type = "schema"
  privileges  = []

  depends_on = [azurerm_postgresql_database.service_name, azurerm_postgresql_firewall_rule.public_access]
}


resource "postgresql_schema" "service_name" {
  name     = var.service_name
  database = azurecaf_name.postgresql_database.result
  owner    = local.postgres_user_name

  depends_on = [
    azurerm_postgresql_database.service_name,
    azurerm_postgresql_firewall_rule.public_access
  ]
}

resource "azurerm_key_vault_secret" "database_user" {
  name         = "database-user"
  value        = local.database_user
  key_vault_id = azurerm_key_vault.service_name.id

  depends_on = [
    azurerm_key_vault_access_policy.terraform_provisioner
  ]
}

resource "azurerm_key_vault_secret" "database_password" {
  name         = "database-password"
  value        = postgresql_role.service_name.password
  key_vault_id = azurerm_key_vault.service_name.id

  depends_on = [
    azurerm_key_vault_access_policy.terraform_provisioner
  ]
}

resource "azurerm_key_vault_secret" "database_connection_string" {
  name         = "database-connection-string"
  value        = local.database_connection_string
  key_vault_id = azurerm_key_vault.service_name.id

  depends_on = [
    azurerm_key_vault_access_policy.terraform_provisioner
  ]
}
