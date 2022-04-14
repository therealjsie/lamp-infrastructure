
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

variable "postgres_admin_user" {
  default     = "psqladmin"
  description = "Value of the postgres_admin_user provisioned in this module."
}
