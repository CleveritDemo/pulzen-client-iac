output "app_url" {
  value = module.gcp[0].app_url
}

output "app_url_swagger" {
  value = "${module.gcp[0].app_url}/swagger-ui/index.html"
}

# Output the Cosmos DB Account Name from Azure module if db_engine is cosmosdb
output "cosmosdb_account_name" {
  value = var.db_engine == "cosmosdb" ? module.azure[0].cosmosdb_account_name : ""
  description = "The name of the Cosmos DB account"
}

# Output the Cosmos DB Database Name from Azure module if db_engine is cosmosdb
output "cosmosdb_database_name" {
  value = var.db_engine == "cosmosdb" ? module.azure[0].cosmosdb_database_name : ""
  description = "The name of the Cosmos DB MongoDB database"
}

# Output the MongoDB URI from Azure module if db_engine is cosmosdb
output "mongodb_uri" {
  value = var.db_engine == "cosmosdb" ? module.azure[0].mongodb_uri : ""
  description = "The connection string for MongoDB in CosmosDB"
}

# Output the Cosmos DB Resource Group Name from Azure module if db_engine is cosmosdb
output "cosmosdb_resource_group" {
  value = var.db_engine == "cosmosdb" ? module.azure[0].cosmosdb_resource_group : ""
  description = "The name of the resource group that holds the Cosmos DB"
}

# Output the Container App Environment ID from Azure module if db_engine is cosmosdb
output "container_app_environment_id" {
  value = var.db_engine == "cosmosdb" ? module.azure[0].container_app_environment_id : ""
  description = "The ID of the container app environment"
}

# Output the Managed Identity Principal ID from Azure module if db_engine is cosmosdb
output "managed_identity_principal_id" {
  value = var.db_engine == "cosmosdb" ? module.azure[0].managed_identity_principal_id : ""
  description = "The principal ID of the managed identity used by the container app"
}

