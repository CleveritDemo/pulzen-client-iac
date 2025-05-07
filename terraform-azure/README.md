### Run terraform script

Client side script to provision the Pulsen client resources necesaary on the client side.

## STATUS: **WIP**

- GCP:
  - Working with GCP + Atlas: DONE
  - GCP + manual mongodb string: inProgress
- Azure:
  - Working with Azure + CosmosDB for Mongo: DONE
  - Azure + manual mongodb string: DONE
- AWS:
  - Working with AWS + Atlas : pending
  - AWS + manual mongodb string: pending

## Prerequisites

- Terraform
- Cloud Cli (one of the following is required)
  - AWS CLI
  - gcloud CLI
  - Azure CLI
- update the `client.tfvars` file with the required values

## Steps

First, init the cloud CLI with the required credentials and account to be used:

# GCP

```bash
gcloud auth application-default login
```

# AWS

```bash
aws configure
```

# Azure

```bash
az login
```

> Second, make sure to have the required terraform script and the `client.tfvars` file updated with the required values. You can find a template file for it in ./client.tfvars.template file, just copy it and update the values (deleting the .template part of the name).

Third, run the following commands:

# Terraform commands

```bash
# Initialize the terraform: first time only
terraform init
```

```bash
# Plan the terraform script: to see the changes without applying them
terraform plan -var-file=ansiblefeeded.tfvars -out=tfplan
```

```bash
# Apply the terraform script: to apply the changes -> create the resources
terraform apply tfplan
```

## Destroy

```bash
# Destroy the resources
terraform destroy -var-file=ansiblefeeded.tfvars
```

```bash
# Banco estado
terraform plan -var-file=bancoestado.tfvars -out=tfplan
terraform apply tfplan
terraform destroy -var-file=bancoestado.tfvars

# Banco Chile
terraform plan -var-file=bancochile.tfvars -out=tfplan
terraform apply tfplan
terraform destroy -var-file=bancochile.tfvars

# Lirmi GITHUB_WEBHOOK_SECRET = "9N(wxXYs{<kc)9Y:iwL^CTmB?h${0|"
terraform plan -var-file=lirmi.tfvars -out=tfplan
terraform apply tfplan
terraform destroy -var-file=lirmi.tfvars
```
