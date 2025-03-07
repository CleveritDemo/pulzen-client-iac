# Create Cosmos DB Account with MongoDB API
resource "azurerm_cosmosdb_account" "mongo" {
  name                = "${var.app_name}-cosmosdb"
  location            = var.location
  resource_group_name = var.resource_group
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

# Create Cosmos DB MongoDB Database
resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  name                = var.db_name
  resource_group_name = var.resource_group
  account_name        = azurerm_cosmosdb_account.mongo.name
}

# Get Cosmos DB Connection String
data "azurerm_cosmosdb_account" "mongo_data" {
  name                = azurerm_cosmosdb_account.mongo.name
  resource_group_name = var.resource_group
}

# Create Container Apps Environment
resource "azurerm_container_app_environment" "env" {
  name                = "${var.app_name}-env"
  resource_group_name = var.resource_group
  location            = var.location
}

# Deploy Azure Container App
resource "azurerm_container_app" "app" {
  name                       = var.app_name
  resource_group_name        = var.resource_group
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode              = "Single"

  template {
    container {
      name   = var.app_name
      image  = var.container_image
      cpu    = 2
      memory = "2Gi"

      env {
        name  = "MONGODB"
        value = azurerm_cosmosdb_account.mongo.primary_mongodb_connection_string
      }

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
