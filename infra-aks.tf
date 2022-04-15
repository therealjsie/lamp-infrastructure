# This file contains all resources for the provisioning of AKS and for the configuration of peripheral systems.

resource "azurecaf_name" "aks_cluster" {
  name          = var.service_name
  suffixes      = [var.stage_name]
  resource_type = "azurerm_kubernetes_cluster"
  clean_input   = true
}

resource "azurerm_kubernetes_cluster" "service_name" {
  name                             = azurecaf_name.aks_cluster.result
  dns_prefix                       = azurecaf_name.aks_cluster.result
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

  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  tags = {
    "application" = var.service_name,
    "stage"       = var.stage_name
  }
}

resource "azuread_application" "service_name" {
  display_name = local.service_principal_name
}

resource "azuread_service_principal" "service_name" {
  application_id = azuread_application.service_name.application_id
}

resource "azurerm_role_assignment" "service_name" {
  scope                = azurerm_resource_group.service_name.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.service_name.id
}

resource "azurerm_key_vault_access_policy" "service_name" {
  key_vault_id = azurerm_key_vault.service_name.id
  object_id    = azurerm_kubernetes_cluster.service_name.key_vault_secrets_provider.0.secret_identity.0.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]
}
