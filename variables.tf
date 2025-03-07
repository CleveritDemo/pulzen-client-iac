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

variable "mongodb_password" {
  description = "MongoDB Password"
  type        = string
}

variable "mongodb_username" {
  description = "MongoDB Username"
  type        = string
}

variable "mongodb_databse_tier" {
  description = "MongoDB Database Tier"
  type        = string
}