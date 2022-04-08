
variable "service_name" {
  description = "Name of the service that will be deployed through this module."
}

variable "stage_name" {
  description = "Name of the stage that this infrastructure will be deployed to."
}

variable "location" {
  default     = "Germany West Central"
  description = "Location of the resources created by this module."
}

variable "postgres_admin_password" {
  description = "Value of the postgres_admin_password provisioned in this module."
}

locals {
  resource_group_name  = format("%s-%s", var.service_name, var.stage_name)
  aks_cluster_name     = format("%s-aks-%s", var.service_name, var.stage_name)
  postgres_server_name = format("%s-postgres-%s", var.service_name, var.stage_name)
}
