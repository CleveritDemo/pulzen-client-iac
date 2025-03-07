provider "google" {
  project = var.project_id
  region  = var.region
}

# Create MongoDB Atlas or Firestore with MongoDB compatibility
resource "google_firestore_database" "mongo" {
  project     = var.project_id
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
  name        = var.db_name
}

# Create Cloud Run Service
resource "google_cloud_run_service" "app" {
  name     = var.app_name
  location = var.region
  project  = var.project_id

  template {
    spec {
      containers {
        image = var.container_image

        env {
          name  = "MONGO_STRING"
          value = "mongodb+srv://${google_firestore_database.mongo.name}.${var.project_id}.firebasedatabase.app"
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
