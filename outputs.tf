output "mongodb_connection_string" {
  value = var.cloud_provider == "gcp" ? module.gcp[0].mongodb_connection_string : (
          var.cloud_provider == "azure" ? module.azure[0].mongodb_connection_string : ""
          )
}

output "app_url" {
  value = var.cloud_provider == "gcp" ? module.gcp[0].app_url : (
          var.cloud_provider == "azure" ? module.azure[0].app_url : ""
          )
}