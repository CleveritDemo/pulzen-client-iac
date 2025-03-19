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

variable "db_engine" {
  description = "Database Engine"
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
