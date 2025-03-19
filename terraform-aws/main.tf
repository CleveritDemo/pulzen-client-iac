module "azure" {
  source = "./modules/aws"
  count  = var.cloud_provider == "aws" ? 1 : 0

  providers = {
    azurerm       = azurerm
    random        = random
  }

  app_name        = var.app_name
  container_image = var.container_image
  db_engine       = var.db_engine
  env_vars        = var.env_vars
  location        = var.location
  project_labels  = var.project_labels
  db_password = var.db_password
  db_username = var.db_username
}
