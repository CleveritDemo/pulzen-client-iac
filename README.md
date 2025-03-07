### Run terraform script

Client side script to provision the Pulsen client resources necesaary on the client side.

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

> Second, make sure to have the required terraform script and the `client.tfvars` file updated with the required values.

Third, run the following commands:

# Terraform commands

```bash
# Initialize the terraform: first time only
terraform init
```

```bash
# Plan the terraform script: to see the changes without applying them
terraform plan -var-file=client.tfvars
```

```bash
# Apply the terraform script: to apply the changes -> create the resources
terraform apply -var-file=client.tfvars
```

## Destroy

```bash
# Destroy the resources
terraform destroy -var-file=client.tfvars
```
