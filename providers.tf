terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.14"
    }

    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.service_name.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.service_name.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.service_name.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.service_name.kube_config.0.cluster_ca_certificate)
}

provider "postgresql" {
  host      = azurerm_postgresql_server.service_name.fqdn
  port      = 5432
  username  = format("%s@%s", var.postgres_admin_user, azurerm_postgresql_server.service_name.name)
  password  = random_password.postgres_admin.result
  sslmode   = "require"
  superuser = false
}
