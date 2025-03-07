resource "mongodbatlas_project" "pulzenmongo" {
  name   = var.app_name
  org_id = var.mongodb_atlas_org_id
}

resource "mongodbatlas_cluster" "pulzenmongocluster" {
  project_id   = mongodbatlas_project.pulzenmongo.id
  name         = var.db_name
  provider_name = "GCP"
  backing_provider_name = "GCP"
  provider_region_name = var.region
  provider_instance_size_name = var.mongodb_databse_tier
}

resource "mongodbatlas_database_user" "pulzenmongouser" {
  username    = var.mongodb_username
  password    = var.mongodb_password
  project_id  = mongodbatlas_project.pulzenmongo.id
  auth_database_name = "admin"
  
  roles {
    role_name     = "readWrite"
    database_name = var.db_name
  }
}

resource "google_cloud_run_service" "app" {
  name     = var.app_name
  location = var.region
  project  = var.project_id

  template {
    metadata {
      labels = var.project_labels
    }
    spec {
      containers {
        image = var.container_image

        env {
          name  = "MONGODB"
          value = mongodbatlas_cluster.pulzenmongocluster.connection_strings[0].standard_srv
        }

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }
      }
    }
  }
}

# Make Cloud Run Public
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.app.name
  location = google_cloud_run_service.app.location
  project  = google_cloud_run_service.app.project
  role     = "roles/run.invoker"
  member   = "allUsers"
}
