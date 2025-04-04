module "azure" {
  source = "./modules/azure"
  count  = var.cloud_provider == "azure" ? 1 : 0

  providers = {
    azurerm       = azurerm
    random        = random
  }

  # Application
  app_name        = var.app_name
  container_image = var.container_image
  db_engine       = var.db_engine
  env_vars        = var.env_vars
  
  # Azure
  resource_group  = "${var.app_name}-rg"
  location        = var.location
  project_labels  = var.project_labels

  # Database
  db_password = var.db_password
  db_username = var.db_username
  cosmos_unique_postfix = var.cosmos_unique_postfix
  db_url = var.db_url
  mongodb_databse_tier = var.mongodb_databse_tier

  # Networking
  vnet_cidr = var.vnet_cidr
  container_subnet_cidr = var.container_subnet_cidr
  db_subnet_cidr = var.db_subnet_cidr
}
