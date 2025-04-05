output "app_url" {
  value = var.cloud_provider == "aws" && var.db_engine == "documentdb" ? module.aws[0].app_url : ""
}

output "app_url_swagger" {
  value = var.cloud_provider == "aws" && var.db_engine == "documentdb" ? "${module.aws[0].app_url}/swagger-ui/index.html" : ""
}
