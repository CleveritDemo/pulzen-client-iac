# Ansible Deploy

This is a simple ansible playbook to deploy a simple web application.

## Prerequisites

- Ansible
- Terraform
- gcloud CLI
- update the `client.tfvars` file with the required values

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

## Steps

First, init the cloud CLI with the required credentials and account to be used:

```bash
gcloud auth application-default login
```

Second, make sure to have the required terraform script and the `client.tfvars` file updated with the required values. You can find a template file for it in ./client.tfvars.template file, just copy it and update the values (deleting the .template part of the name).

# Ansible commands

Testing if all is working fine:

```bash
# Ansible test command
ansible-playbook -i ansible/inventories/localhost/hosts.yaml ansible/playbooks/test_ansible.yml

# gcloud cli test command run ansible/roles/gcp/tasks/test_gcloud_cli.yml with ansible/group_vars/gcp.yaml
ansible-playbook -i ansible/inventory/localhost/hosts.yaml ansible/playbooks/test_gcloud_cli.yml
ansible-playbook ansible/playbooks/test_gcloud_cli.yml

```

Deploying Mongodb Cluster in Atlas using the GCP Marketplace (gcloud cli as tool):

```bash
# Deploying Mongodb Cluster in Atlas using the GCP Marketplace
ansible-playbook -i ansible/inventories/localhost/hosts.yaml ansible/roles/gcp/tasks/mongodb_atlas_deploy.yml

# Destroying Mongodb Cluster in Atlas using the GCP Marketplace
ansible-playbook -i ansible/inventories/localhost/hosts.yaml ansible/roles/gcp/tasks/mongodb_atlas_destroy.yml
```
