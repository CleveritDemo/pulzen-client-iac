variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "db_url" {
  description = "Database connection string"
  type        = string
}

variable "env_vars" {
  description = "Environment variables for the application"
  type        = map(string)
}

variable "location" {
  description = "AWS Region"
  type        = string
  default     = "East US"
}

variable "project_labels" {
  description = "Labels for the project"
  type        = map(string)
}

variable "vnet_cidr" {
  description = "value for the virtual network CIDR block"
  type        = string
}

variable "container_subnet_cidr" {
  description = "value for the subnet CIDR block"
  type        = string
  default = "10.0.0.0/23"
}