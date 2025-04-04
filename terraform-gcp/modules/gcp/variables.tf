variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
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

variable "db_engine" {
  description = "Database Engine"
  type        = string
}

variable "env_vars" {
  description = "Environment variables for the application"
  type        = map(string)
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_labels" {
  description = "Labels for the project"
  type        = map(string)
}

variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas Public Key"
  type        = string
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas Private Key"
  type        = string
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "mongodb_databse_tier" {
  description = "MongoDB Database Tier"
  type        = string
}

variable "mongodb_region" {
  description = "MongoDB Region"
  type        = string
}

variable "vnet_cidr" {
  description = "value for the virtual network CIDR block"
  type        = string  
  default = "10.0.0.0/20"
}

variable "container_subnet_cidr" {
  description = "value for the subnet CIDR block"
  type        = string
  default = "10.0.0.0/23"
}

variable "db_subnet_cidr" {
  description = "value for the subnet CIDR block"
  type        = string
  default = "10.0.2.0/24"
}