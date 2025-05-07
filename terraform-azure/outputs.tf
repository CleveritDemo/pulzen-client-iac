output "app_url" {
  value = length(module.azure) > 0 ? module.azure[0].app_url : module.azure-mongoatlas-connectionstring[0].app_url
}

output "app_url_swagger" {
  value = length(module.azure) > 0 ? "${module.azure[0].app_url}/swagger-ui/index.html" : "${module.azure-mongoatlas-connectionstring[0].app_url}/swagger-ui/index.html"
}