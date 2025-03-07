module "gcp" {
  source = "./modules/gcp"
  count  = var.cloud_provider == "gcp" ? 1 : 0

  providers = {
    google        = google
    mongodbatlas  = mongodbatlas
  }

  app_name        = var.app_name
  container_image = var.container_image
  db_name         = var.db_name
  env_vars        = var.env_vars
  project_id      = var.project_id
  region          = var.location
  project_labels  = var.project_labels
  mongodb_atlas_org_id = var.mongodb_atlas_org_id
  mongodb_atlas_public_key = var.mongodb_atlas_public_key
  mongodb_atlas_private_key = var.mongodb_atlas_private_key
  mongodb_password = var.mongodb_password
  mongodb_username = var.mongodb_username
  mongodb_databse_tier = var.mongodb_databse_tier
  mongodb_region = var.mongodb_region
}

module "azure" {
  source = "./modules/azure"
  count  = var.cloud_provider == "azure" ? 1 : 0

  providers = {
    azurerm       = azurerm
    mongodbatlas  = mongodbatlas
  }

  app_name        = var.app_name
  container_image = var.container_image
  db_name         = var.db_name
  env_vars        = var.env_vars
  resource_group  = var.resource_group
  location        = var.location
  project_labels  = var.project_labels
  mongodb_atlas_org_id = var.mongodb_atlas_org_id
  mongodb_atlas_public_key = var.mongodb_atlas_public_key
  mongodb_atlas_private_key = var.mongodb_atlas_private_key
  mongodb_password = var.mongodb_password
  mongodb_username = var.mongodb_username
  mongodb_databse_tier = var.mongodb_databse_tier
}
