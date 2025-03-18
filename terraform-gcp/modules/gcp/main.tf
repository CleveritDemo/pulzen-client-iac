# Deploy atlas cluster
module "mongodbatlas" {
  source = "../mongodbatlas"
  count  = var.db_engine == "mongodbatlas" ? 1 : 0

  providers = {
    mongodbatlas  = mongodbatlas
  }

  app_name        = var.app_name
  mongodb_atlas_org_id = var.mongodb_atlas_org_id
  mongodb_atlas_public_key = var.mongodb_atlas_public_key
  mongodb_atlas_private_key = var.mongodb_atlas_private_key
  db_password = var.db_password
  db_username = var.db_username
  mongodb_databse_tier = var.mongodb_databse_tier
  mongodb_region = var.mongodb_region
}

# Define db connection string for atlas or given connection_string (db_url)
locals {
  mongodb_connection_string = var.db_engine == "mongodbatlas" && length(module.mongodbatlas) > 0 ? module.mongodbatlas[0].mongodb_connection_string : var.db_url
}

# Define a list of active dependencies
# locals {
#   db_dependency = var.db_engine == "mongodbatlas" ? [module.mongodbatlas] : [module.mongodbatlas]
# }

# Deploy Cloud Run service
resource "google_cloud_run_service" "app" {
  name     = var.app_name
  location = var.region
  project  = var.project_id
  depends_on = [module.mongodbatlas]

  template {
    metadata {
      labels = var.project_labels
      annotations = {
        "autoscaling.knative.dev/minScale" = "1"
        "autoscaling.knative.dev/maxScale" = "1"
      }
    }
    spec {
      containers {
        name = var.app_name
        image = var.container_image
        ports {
          container_port = 8080
        }

        resources {
          limits = {
            "cpu" = "2"
            "memory" = "8Gi"
          }
        }

        env {
          name  = "MONGODB"
          value = local.mongodb_connection_string
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

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Make Cloud Run Public
resource "google_cloud_run_service_iam_member" "public_access" {
  depends_on = [ google_cloud_run_service.app ]

  service  = google_cloud_run_service.app.name
  location = google_cloud_run_service.app.location
  project  = google_cloud_run_service.app.project
  role     = "roles/run.invoker"
  member   = "allUsers"
}