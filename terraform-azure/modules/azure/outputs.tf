output "app_url" {
  value       = "https://${azurerm_container_app.app.latest_revision_fqdn}"
  description = "The public URL of the container app"
}

# Output the Cosmos DB Account Name
output "cosmosdb_account_name" {
  value = azurerm_cosmosdb_account.mongo.name
  description = "The name of the Cosmos DB account"
}

# Output the Cosmos DB Database Name
output "cosmosdb_database_name" {
  value = azurerm_cosmosdb_mongo_database.mongo_db.name
  description = "The name of the Cosmos DB MongoDB database"
}

# Output the MongoDB URI (for container app usage or other references)
output "mongodb_uri" {
  value = "mongodb://${var.db_username}:${var.db_password}@${azurerm_cosmosdb_account.mongo.name}.mongo.cosmos.azure.com:10255/${azurerm_cosmosdb_mongo_database.mongo_db.name}?ssl=true&retrywrites=false&authSource=admin"
  description = "The connection string for MongoDB in CosmosDB"
}

# Output the Cosmos DB Resource Group Name
output "cosmosdb_resource_group" {
  value = azurerm_resource_group.pulzen-rg.name
  description = "The name of the resource group that holds the Cosmos DB"
}

# Output the Container App Environment ID
output "container_app_environment_id" {
  value = azurerm_container_app_environment.env.id
  description = "The ID of the container app environment"
}

# Output the Managed Identity Principal ID
output "managed_identity_principal_id" {
  value = azurerm_user_assigned_identity.app_identity.principal_id
  description = "The principal ID of the managed identity used by the container app"
}
