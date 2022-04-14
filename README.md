# lamp-infra Repository

This is a barebone infrastructure setup for a sample service that runs in AKS
and uses an Azure-managed PostgreSQL database.

## Prerequisites

- Terraformb
- Azure subscription

Ref:
https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration

## How to provision infrastructure from a local machine

Use this guide to get configuration instructions for working with Terraform on
Azure:

https://docs.microsoft.com/en-us/azure/developer/terraform/overview

The following environment variables should be set to enable Terraform to
provision infrastructure on Azure:

- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET

Use `terraform plan` followed by `terraform apply` to provision infrastructure
in Azure through Terraform. Examples can be found here:

https://learn.hashicorp.com/collections/terraform/azure-get-started

## How to provision infrastructure from Terraform Cloud

...

# Further considerations

This project aims to use as few Azure resources outside the free tier as
possible. In some cases, this results in resources that are not production-ready
(i.e. cluster architecture of AKS resource).

## General considerations

https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/secure-baseline-aks

## Load Balancing

https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/load-balancing-overview
