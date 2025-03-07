output "mongodb_connection_string" {
  value = mongodbatlas_cluster.pulzenmongocluster.connection_strings[0].standard_srv
  sensitive = true
}

output "app_url" {
  value = google_cloud_run_service.app.status[0].url
}
