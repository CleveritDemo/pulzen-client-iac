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

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "db_engine" {
  description = "Database Engine"
  type        = string
}

variable "cosmos_unique_postfix" {
  description = "Unique prefix for CosmosDB (to make it globally unique)"
  type        = string
}

variable "db_url" {
  description = "Database URL"
  type        = string
}

variable "db_username" {
  description = "Database Username"
  type        = string
}

variable "db_password" {
  description = "Database Password"
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

variable "project_labels" {
  description = "Labels for the project"
  type        = map(string)
}

variable "mongodb_databse_tier" {
  description = "MongoDB Database Tier"
  type        = string
}

variable "mongodb_region" {
  description = "MongoDB Region"
  type        = string
}

variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
  default     = ""  # Empty string as a default
}

variable "vnet_cidr" {
  description = "value for the virtual network CIDR block"
  type        = string  
}

variable "container_subnet_cidr_a" {
  description = "value for the subnet CIDR block"
  type        = string
}

variable "container_subnet_cidr_b" {
  description = "value for the subnet CIDR block"
  type        = string
}

variable "db_subnet_cidr_a" {
  description = "value for the subnet CIDR block"
  type        = string
}

variable "db_subnet_cidr_b" {
  description = "value for the subnet CIDR block"
  type        = string
}
