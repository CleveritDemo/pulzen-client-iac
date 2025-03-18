variable "app_name" {
  description = "Name of the application"
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

variable "vm_size" {
  description = "Size of the VM"
  default = "n1-standard-2"
  type        = string
}

variable "zone" {
  description = "GCP Zone"
  default     = "us-central1-a"
  type        = string
}