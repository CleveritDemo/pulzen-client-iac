output "mongo_connection_string" {
  value = "mongodb+srv://${google_firestore_database.mongo.name}.${var.project_id}.firebasedatabase.app"
}

output "cloud_run_url" {
  value = google_cloud_run_service.app.status[0].url
}
