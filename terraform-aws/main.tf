module "aws" {
  source = "./modules/aws"
  count  = var.cloud_provider == "aws" ? 1 : 0

  providers = {
    aws       = aws
    random    = random
  }

  app_name        = var.app_name
  container_image = var.container_image
  db_url          = var.db_url
  env_vars        = var.env_vars
  location        = var.location
  project_labels  = var.project_labels
  vnet_cidr       = var.vnet_cidr
  container_subnet_cidr = var.container_subnet_cidr
}
