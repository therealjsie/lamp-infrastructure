# This file contains all foundational resources that are required by AKS, Postgres, etc.

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "service_name" {
  name     = local.resource_group_name
  location = var.location
  tags = {
    "application" = var.service_name,
    "stage"       = var.stage_name
  }
}

# Ref.: https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/azurecaf_name
resource "azurecaf_name" "key_vault" {
  name          = var.service_name
  suffixes      = [var.stage_name]
  resource_type = "azurerm_key_vault"
  clean_input   = true
}

resource "azurerm_key_vault" "service_name" {
  name                = azurecaf_name.key_vault.result
  resource_group_name = azurerm_resource_group.service_name.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

# All possible values are for the permissions are listed in the documentation of the terraform module.
# Ref.: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy
resource "azurerm_key_vault_access_policy" "terraform_provisioner" {
  key_vault_id = azurerm_key_vault.service_name.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Update",
    "Delete"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge"
  ]
}
