locals {
  resource_group_name        = format("%s-service-%s", var.service_name, var.stage_name)
  aks_cluster_name           = format("%s-service", var.service_name)
  service_principal_name     = format("%s-%s-service-principal", var.service_name, var.stage_name)
  postgres_user_name         = format("%s_user", var.service_name)
  database_user              = format("%s@%s", local.postgres_user_name, azurecaf_name.postgresql_server.result)
  database_connection_string = format("jdbc:postgresql://%s.postgres.database.azure.com/%s", azurecaf_name.postgresql_server.result, azurecaf_name.postgresql_database.result)
}
