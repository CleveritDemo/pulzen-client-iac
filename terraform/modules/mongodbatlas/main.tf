resource "mongodbatlas_project" "pulzenmongo" {
  name   = var.app_name
  org_id = var.mongodb_atlas_org_id
}

resource "mongodbatlas_cluster" "pulzenmongocluster" {
  project_id   = mongodbatlas_project.pulzenmongo.id
  name         = "${var.app_name}-db"
  cluster_type = "REPLICASET"

  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.mongodb_region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }

  cloud_backup                 = true
  auto_scaling_disk_gb_enabled = true

  # Provider Settings "block"
  provider_name = "GCP"
  provider_instance_size_name = var.mongodb_databse_tier
}

resource "mongodbatlas_database_user" "pulzenmongouser" {
  username    = var.db_username
  password    = var.db_password
  project_id  = mongodbatlas_project.pulzenmongo.id
  auth_database_name = "admin"
  
  roles {
    role_name     = "readWrite"
    database_name = "${var.app_name}-db"
  }
}
