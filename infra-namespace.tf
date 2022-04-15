resource "kubernetes_namespace" "service_name" {
  metadata {
    name = var.service_name
  }

  depends_on = [
    azurerm_kubernetes_cluster.service_name,
  ]
}

# Don't try kubernetes_manifest resource. See: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/alpha-manifest-migration-guide#mixing-kubernetes_manifest-with-other-kubernetes_-resources
resource "helm_release" "crds" {
  name      = "cluster-setup-chart"
  chart     = "./cluster-setup-chart"
  namespace = var.service_name

  set {
    name  = "appName"
    value = var.service_name
  }

  set {
    name  = "keyVaultName"
    value = azurecaf_name.key_vault.result
  }

  set {
    name  = "tenantId"
    value = data.azurerm_client_config.current.tenant_id
  }

  set {
    name  = "secretProviderIdentityId"
    value = azurerm_kubernetes_cluster.service_name.key_vault_secrets_provider.0.secret_identity.0.client_id
  }
}
