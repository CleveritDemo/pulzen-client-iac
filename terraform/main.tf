module "gcp" {
  source = "./modules/gcp"
  count  = var.cloud_provider == "gcp" ? 1 : 0

  providers = {
    google        = google
    mongodbatlas  = mongodbatlas
  }

  app_name        = var.app_name
  container_image = var.container_image
  db_engine       = var.db_engine
  env_vars        = var.env_vars
  project_id      = var.project_id
  region          = var.location
  project_labels  = var.project_labels
  mongodb_atlas_org_id = var.mongodb_atlas_org_id
  mongodb_atlas_public_key = var.mongodb_atlas_public_key
  mongodb_atlas_private_key = var.mongodb_atlas_private_key
  db_password = var.db_password
  db_username = var.db_username
  db_url = var.db_url
  mongodb_databse_tier = var.mongodb_databse_tier
  mongodb_region = var.mongodb_region
}

module "azure" {
  source = "./modules/azure"
  count  = var.cloud_provider == "azure" ? 1 : 0

  providers = {
    azurerm       = azurerm
    random        = random
  }

  app_name        = var.app_name
  container_image = var.container_image
  db_engine       = var.db_engine
  env_vars        = var.env_vars
  resource_group  = "${var.app_name}-rg"
  location        = var.location
  project_labels  = var.project_labels
  mongodb_atlas_org_id = var.mongodb_atlas_org_id
  mongodb_atlas_public_key = var.mongodb_atlas_public_key
  mongodb_atlas_private_key = var.mongodb_atlas_private_key
  db_password = var.db_password
  db_username = var.db_username
  db_url = var.db_url
  mongodb_databse_tier = var.mongodb_databse_tier
}
