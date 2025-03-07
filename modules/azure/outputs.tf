output "mongo_connection_string" {
  value = data.azurerm_cosmosdb_account.mongo_data.connection_strings[0]
}

output "container_app_url" {
  value = azurerm_container_app.app.latest_revision_fqdn
}
