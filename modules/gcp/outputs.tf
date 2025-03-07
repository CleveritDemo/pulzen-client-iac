output "mongodb_connection_string" {
  value = "mongodb+srv://${var.mongodb_username}:${var.mongodb_password}@${replace(mongodbatlas_cluster.pulzenmongocluster.connection_strings[0].standard_srv, "mongodb+srv://", "")}/${var.db_name}?retryWrites=true&w=majority"
  sensitive = true
}

output "app_url" {
  value = google_cloud_run_service.app.status[0].url
}
