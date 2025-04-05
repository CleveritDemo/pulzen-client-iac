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
  description = "AWS Region"
  type        = string
  default     = "us-est-2"
}

variable "project_labels" {
  description = "Labels for the project"
  type        = map(string)
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

variable "docdb_instance_class" {
  description = "Instance class for DocumentDB"
  type        = string
  default     = "db.t4g.medium"
}