resource "mongodbatlas_project" "pulzenmongo" {
  name   = var.app_name
  org_id = var.mongodb_atlas_org_id
}

resource "mongodbatlas_cluster" "pulzenmongocluster" {
  project_id   = mongodbatlas_project.pulzenmongo.id
  name         = var.db_name
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
  depends_on = [ mongodbatlas_cluster.pulzenmongocluster ]

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
            "memory" = "4Gi"
          }
        }

        env {
          name  = "MONGODB"
          value = "mongodb+srv://${var.mongodb_username}:${var.mongodb_password}@${replace(mongodbatlas_cluster.pulzenmongocluster.connection_strings[0].standard_srv, "mongodb+srv://", "")}/${var.db_name}?retryWrites=true&w=majority"
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
  service  = google_cloud_run_service.app.name
  location = google_cloud_run_service.app.location
  project  = google_cloud_run_service.app.project
  role     = "roles/run.invoker"
  member   = "allUsers"
}
