# lamp-infra Repository

This is the infrastructure definition for a service that is deployed in an AKS
cluster and uses an Azure-managed PostgreSQL database as well as Azure Key
Vault. Please note, the infrastructure definition is not production-ready.

The goal of this repository is to provide basic infrastructure for the
lamp-service in the
[lamp-app Repository](https://github.com/therealjsie/lamp-app).

## Prerequisites

- Terraform CLI
- Azure subscription
- Optional: Terraform Cloud

The Terraform workspace needs to be configured to have access to the target
Azure subscription (e.g.
[through a service principal with a secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)).
The executing user needs to have access rights to grant privileges to other
users (e.g. the built-in `Owner` role in Azure).

## Deployment

The infrastruction definition can be deployed either through a local workspace
or via Terraform cloud.

## Parameter reference

| Name                  | Type     | Description                                                                             | Required/Optional | Default              |
| --------------------- | -------- | --------------------------------------------------------------------------------------- | ----------------- | -------------------- |
| `service_name`        | `string` | The name of the service that will be deployed with this infrastructure.                 | **Required**      | -                    |
| `stage_name`          | `string` | The name of the stage that will be deployed.                                            | **Required**      | -                    |
| `location`            | `string` | The location of the DC where the infrastructure will be deployed.                       | Optional          | Germany West Central |
| `postgres_admin_user` | `string` | The name of the Postgres admin that will be configured during the infrastructure setup. | Optional          | psqladmin            |

Additionally, make sure that the workspace is configured to have access to the
target Azure subscription.
