output "mongodb_connection_string" {
  value = azurerm_cosmosdb_account.mongo.primary_mongodb_connection_string
  sensitive = true
}

output "app_url" {
  value = azurerm_container_app.app.latest_revision_fqdn
}
