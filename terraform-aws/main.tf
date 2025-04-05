module "aws" {
  source = "./modules/aws"
  count  = var.cloud_provider == "aws" ? 1 : 0

  providers = {
    aws       = aws
    random    = random
  }

  # Application
  app_name        = var.app_name
  container_image = var.container_image
  db_engine       = var.db_engine
  env_vars        = var.env_vars
  
  # AWS
  location        = var.location
  project_labels  = var.project_labels

  # Database
  db_password = var.db_password
  db_username = var.db_username

  # Networking
  vnet_cidr = var.vnet_cidr
  container_subnet_cidr_a = var.container_subnet_cidr_a
  container_subnet_cidr_b = var.container_subnet_cidr_b
  db_subnet_cidr_a = var.db_subnet_cidr_a
  db_subnet_cidr_b = var.db_subnet_cidr_b
}
