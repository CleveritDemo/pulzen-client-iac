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

variable "env_vars" {
  description = "Environment variables for the application"
  type        = map(string)
}

variable "resource_group" {
  description = "Azure Resource Group"
  type        = string
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