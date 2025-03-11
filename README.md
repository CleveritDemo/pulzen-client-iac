# Ansible Deploy

This is a simple ansible playbook to deploy a simple web application.

## Prerequisites

- Ansible
- Terraform
- Cloud Cli (one of the following is required)
  - [gcloud CLI (Initialized and with the desired project selected)](https://cloud.google.com/sdk/docs/install)
  - [Azure cli (Initialized and with the desired subscription selected)](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- copy/paste the ./base_variables.yaml.template to ./base_variables.yaml and update the values

> NOTE 1: **ALL** the resouces will be created on the subscrition/project currently selected on the CLI for the logged in user. Make sure to have the correct subscription/project selected on you cloud cli.

> NOTE 2: Is vital to follow the instructions for the creation of the ./base_variables.yaml file, and the required values MUST be updated.

## Check/Install Ansible

```bash
ansible --version
```

If not installed, you can install it with the following command:

```bash
# Macos Brew
brew install ansible

# Ubuntu
sudo apt update
sudo apt install ansible
```

## Check/Install Terraform

```bash
terraform --version
```

If not installed, you can install it with the following command:

```bash
# Macos Brew
brew install terraform

# Ubuntu
sudo apt update
sudo apt install terraform
```

## Steps

First, init the cloud CLI with the required credentials and account to be used:

```bash
# GCP
gcloud auth application-default login

# Azure
az login
```

Second, make sure to have the required terraform script and the `client.tfvars` file updated with the required values. You can find a template file for it in ./client.tfvars.template file, just copy it and update the values (deleting the .template part of the name).

# Ansible commands

## Deploying Pulzen App in GCP + Mongo Atlas as DB [Working] ✅:

```bash
# Deploy (Idempotent)(multiple runs will only update vars and regenerate db password)
ansible-playbook playbooks/deploy_pulzen_mongoatlas_gcp.yml

# Destroy All resources created above (is not reversible)
ansible-playbook playbooks/destroy_pulzen_mongoatlas_gcp.yml
```

## Deploying Pulzen App in GCP + self-hosted MongoDB as DB [WIP] ❌:

```bash
# Deploy (Idempotent)(multiple runs will only update vars and regenerate db password)
ansible-playbook playbooks/deploy_pulzen_mongodb_gcp.yml

# Destroy All resources created above (is not reversible)
ansible-playbook playbooks/destroy_pulzen_mongodb_gcp.yml
```

## Deploying pulzen App in Azure + CosmosDB with mongo API as DB [WIP] ❌:

```bash
# Deploy (Idempotent)(multiple runs will only update vars and regenerate db password)
ansible-playbook playbooks/deploy_pulzen_cosmosdb_azure.yml

# Destroy All resources created above (is not reversible)
ansible-playbook playbooks/destroy_pulzen_cosmosdb_azure.yml
```
