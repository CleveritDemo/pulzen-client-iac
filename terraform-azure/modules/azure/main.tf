resource "azurerm_resource_group" "pulzen-rg" {
  name     = var.resource_group
  location = var.location
}

# VNet with smaller subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.app_name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.pulzen-rg.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "container_subnet" {
  name                 = "container-subnet"
  resource_group_name  = azurerm_resource_group.pulzen-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.container_subnet_cidr]
  depends_on = [ azurerm_virtual_network.vnet ]
}

resource "azurerm_subnet" "cosmosdb_subnet" {
  name                 = "cosmosdb-subnet"
  resource_group_name  = azurerm_resource_group.pulzen-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.db_subnet_cidr]
  depends_on = [ azurerm_virtual_network.vnet ]

  service_endpoints = ["Microsoft.AzureCosmosDB"]
}

# Cosmos DB with Private Endpoint
resource "azurerm_cosmosdb_account" "mongo" {
  name                = "cosmosdb-${var.app_name}-${var.cosmos_unique_postfix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.pulzen-rg.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  
  mongo_server_version = "4.2"

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "EnableMongoRoleBasedAccessControl"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  public_network_access_enabled = false

  is_virtual_network_filter_enabled = true

  virtual_network_rule {
    id = azurerm_subnet.cosmosdb_subnet.id
  }
}

# Create CosmosDB database from account
resource "azurerm_cosmosdb_mongo_database" "mongo_db" {
  account_name = azurerm_cosmosdb_account.mongo.name
  resource_group_name = azurerm_resource_group.pulzen-rg.name
  name = "${var.app_name}-db"

  autoscale_settings {
    max_throughput = 15000
  }
}

# Retrieve the primary connection string for the Cosmos DB account
data "azurerm_cosmosdb_account" "mongo" {
  name                = azurerm_cosmosdb_account.mongo.name
  resource_group_name = azurerm_resource_group.pulzen-rg.name
}

# Extract the username and password from the connection string
locals {
  cosmosdb_endpoint           = data.azurerm_cosmosdb_account.mongo.endpoint
  cosmosdb_primary_key        = data.azurerm_cosmosdb_account.mongo.primary_key
  cosmosdb_connection_string  = "AccountEndpoint=${local.cosmosdb_endpoint};AccountKey=${local.cosmosdb_primary_key};"
  cosmosdb_username           = regex("AccountEndpoint=https://([^.]+)", local.cosmosdb_connection_string)[0]
  cosmosdb_password           = regex("AccountKey=(.*?);", local.cosmosdb_connection_string)[0]
}

# Private Endpoint for CosmosDB
resource "azurerm_private_endpoint" "cosmos_pe" {
  name                = "cosmos-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.pulzen-rg.name
  subnet_id          = azurerm_subnet.cosmosdb_subnet.id

  private_service_connection {
    name                           = "cosmosdb-priv-conn"
    private_connection_resource_id = azurerm_cosmosdb_account.mongo.id
    subresource_names              = ["MongoDB"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "cosmos_dns" {
  name                = "privatelink.mongo.cosmos.azure.com"
  resource_group_name = azurerm_resource_group.pulzen-rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_dns_link" {
  name                  = "cosmos-dns-link"
  resource_group_name   = azurerm_resource_group.pulzen-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_a_record" "cosmos_a_record" {
  name                = azurerm_cosmosdb_account.mongo.name
  zone_name           = azurerm_private_dns_zone.cosmos_dns.name
  resource_group_name = azurerm_resource_group.pulzen-rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.cosmos_pe.private_service_connection[0].private_ip_address]
}

# Container App Environment
resource "azurerm_container_app_environment" "env" {
  name                = "${var.app_name}-env"
  resource_group_name = azurerm_resource_group.pulzen-rg.name
  location            = var.location
  infrastructure_subnet_id   = azurerm_subnet.container_subnet.id
}

# Managed Identity for Container App (to access CosmosDB)
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "${var.app_name}-identity"
  location            = var.location
  resource_group_name = azurerm_resource_group.pulzen-rg.name
}

resource "azurerm_role_assignment" "cosmos_role" {
  scope                = azurerm_cosmosdb_account.mongo.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
}

# Container App with Public HTTPS
resource "azurerm_container_app" "app" {
  name                       = var.app_name
  resource_group_name        = azurerm_resource_group.pulzen-rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode              = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity.id]
  }

  # Predefined secrets
  secret {
    name  = "mongodb-connection"
    value = "mongodb://${local.cosmosdb_username}:${local.cosmosdb_password}@${azurerm_cosmosdb_account.mongo.name}.mongo.cosmos.azure.com:10255/${azurerm_cosmosdb_mongo_database.mongo_db.name}?ssl=true&retrywrites=false&authSource=admin"
  }

  # Dynamically create secrets from var.env_vars
  dynamic "secret" {
    for_each = var.env_vars
    content {
      name  = lower(replace(secret.key, "_", "-"))
      value = secret.value
    }
  }

  template {
    container {
      name   = var.app_name
      image  = var.container_image
      cpu    = 2
      memory = "4Gi"

      # Add environment variables from tfvars
      env {
        name  = "MONGODB"
        secret_name = "mongodb-connection"
      }

      env {
        name = "SPRING_DATA_MONGODB_AUTO_INDEX_CREATION"
        value = "true"
      }

      env {
        name  = "DEBUG"
        value = "false"
      }

      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          secret_name = "${lower(replace(env.key, "_", "-"))}"
        }
      }
    }

    max_replicas = 5
    min_replicas = 1
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.project_labels
}