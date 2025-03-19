variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "db_engine" {
  description = "Databse Engine"
  default    = "cosmosdb"
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

variable "env_vars" {
  description = "Environment variables for the application"
  type        = map(string)
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "East US"
}

variable "project_labels" {
  description = "Labels for the project"
  type        = map(string)
}