variable "cloud_provider" {
  description = "Cloud provider to deploy to (gcp, aws, azure)"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "resource_group" {
  description = "Azure Resource Group"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "db_name" {
  description = "MongoDB database name"
  type        = string
}

variable "location" {
  description = "Azure Region/Google Cloud Region/AWS Region"
  type        = string
  default     = "East US"
}

variable "env_vars" {
  description = "Environment variables for the application"
  type        = map(string)
}

module "gcp" {
  source = "./modules/gcp"
  count  = var.cloud_provider == "gcp" ? 1 : 0

  app_name        = var.app_name
  container_image = var.container_image
  db_name         = var.db_name
  env_vars        = var.env_vars
  project_id      = var.project_id
  region          = var.location
}

module "aws" {
  source = "./modules/aws"
  count  = var.cloud_provider == "aws" ? 1 : 0

  app_name        = var.app_name
  container_image = var.container_image
  db_name         = var.db_name
  env_vars        = var.env_vars
}

module "azure" {
  source = "./modules/azure"
  count  = var.cloud_provider == "azure" ? 1 : 0

  app_name        = var.app_name
  container_image = var.container_image
  db_name         = var.db_name
  env_vars        = var.env_vars
  resource_group  = var.resource_group
  location        = var.location
}

output "mongo_connection_string" {
  value = var.cloud_provider == "gcp" ? module.gcp[0].mongo_connection_string : (
          var.cloud_provider == "aws" ? module.aws[0].mongo_connection_string : (
          var.cloud_provider == "azure" ? module.azure[0].mongo_connection_string : ""
          )
  )
}
