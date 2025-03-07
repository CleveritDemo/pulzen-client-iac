variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "db_name" {
  description = "MongoDB database name"
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

variable "mongodb_region" {
  description = "MongoDB Region"
  type        = string
}