output "app_url" {
  value = var.cloud_provider == "gcp" ? module.gcp[0].app_url : (
          var.cloud_provider == "azure" ? module.azure[0].app_url : ""
          )
}

output "app_url_swagger" {
  value = var.cloud_provider == "gcp" ? module.gcp[0].app_url : (
          var.cloud_provider == "azure" ? module.azure[0].app_url : ""
          )
}

output "app_url_swagger_full" {
  value = var.cloud_provider == "gcp" ? "${module.gcp[0].app_url}/swagger-ui/index.html" : (
          var.cloud_provider == "azure" ? "${module.azure[0].app_url}/swagger-ui/index.html" : ""
          )
}