output "app_url" {
  value       = "https://${azurerm_container_app.app.latest_revision_fqdn}"
  description = "The public URL of the container app"
}