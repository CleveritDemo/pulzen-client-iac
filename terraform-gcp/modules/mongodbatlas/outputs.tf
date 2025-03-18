output "mongodb_connection_string" {
  value = "mongodb+srv://${var.db_username}:${var.db_password}@${replace(mongodbatlas_cluster.pulzenmongocluster.connection_strings[0].standard_srv, "mongodb+srv://", "")}/${var.app_name}-db?retryWrites=true&w=majority"
}