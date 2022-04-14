resource "kubernetes_namespace" "service_name" {
  metadata {
    name = var.service_name
  }

  depends_on = [
    azurerm_kubernetes_cluster.service_name,
  ]
}

resource "kubernetes_manifest" "secretproviderclass" {
  manifest = yamldecode(templatefile("${path.module}/secretproviderclass.yaml.template", {
    appName : var.service_name,
    keyVaultName : azurecaf_name.key_vault.result,
    tenantId : data.azurerm_client_config.current.tenant_id
    secretProviderIdentityId : azurerm_kubernetes_cluster.service_name.key_vault_secrets_provider.0.secret_identity.0.client_id
  }))

  depends_on = [
    kubernetes_namespace.service_name,
  ]
}
