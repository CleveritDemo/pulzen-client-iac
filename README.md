# Pulzen gateway: Ansible + Terraform Deploy

This is the IaC deploy code for the Pulzen gateway on the client selected cloud provider.

## Prerequisites

- Ansible
- Terraform
- Cloud Cli (one of the following is required)
  - [gcloud CLI (Initialized and with the desired project selected)](https://cloud.google.com/sdk/docs/install)
  - [Azure cli (Initialized and with the desired subscription selected)](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- copy/paste the ./base_variables.yaml.template to ./base_variables.yaml and update the values

> NOTE 1: **ALL** the resouces will be created on the subscrition/project currently selected on the CLI for the logged in user. Make sure to have the correct subscription/project selected on you cloud cli.

> NOTE 2: Is vital to follow the instructions for the creation of the ./base_variables.yaml file, and the required values MUST be updated.

> NOTE 3: Make sure you have Owner or User Access Administrator role on the subscription/project you are going to deploy the resources (or the resource creation will fail).

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

### For MongoDB Atlas you will need API Key (public/private keys + org id)

- [Create an API Key](https://www.mongodb.com/docs/atlas/configure-api-access-project/?msockid=1df97124b3fe669d314265e8b247677c#manage-programmatic-access-to-a-project)

Second, make sure to have the copy/pasted and renamed the `base_variables.yaml` file and have it updated with the required values. You can find a template file for it in ./base_variables.yaml.template file, just copy it and update the values (deleting the .template part of the name).

> **WARNING**: You should run only one deploy flavour at a time, as the resources created by one deploy flavour will conflict with the resources created by another deploy flavour. If you want to change from GCP to Azure or vice versa, you should destroy the resources created by the previous deploy flavour before running the new deploy flavour.

# Ansible commands

## Go to ansible folder in the terminal (following commands won't work if you are not in the ansible folder)

```bash
cd ansible
```

## Deploying Pulzen App in GCP + Mongo Atlas as DB ✅:

```bash
# Deploy (Idempotent)(multiple runs will only update vars and regenerate db password)
ansible-playbook playbooks/deploy_pulzen_mongoatlas_gcp.yml

# Destroy All resources created above (is not reversible)
ansible-playbook playbooks/destroy_pulzen_mongoatlas_gcp.yml
```

## Deploying pulzen App in Azure + CosmosDB with mongo API as DB ✅:

```bash
# Deploy (Idempotent)(multiple runs will only update vars and regenerate db password)
ansible-playbook playbooks/deploy_pulzen_mongocosmosdb_azure.yml

# Destroy All resources created above (is not reversible)
ansible-playbook playbooks/destroy_pulzen_mongocosmosdb_azure.yml
```

## Deploying Pulzen App in GCP + self-hosted MongoDB as DB [WIP] ❌:

```bash
# Deploy (Idempotent)(multiple runs will only update vars and regenerate db password)
ansible-playbook playbooks/deploy_pulzen_mongodb_gcp.yml

# Destroy All resources created above (is not reversible)
ansible-playbook playbooks/destroy_pulzen_mongodb_gcp.yml
```

License
This project is licensed under the Apache 2.0 License.


