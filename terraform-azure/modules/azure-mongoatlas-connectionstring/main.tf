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

# Container App Environment
resource "azurerm_container_app_environment" "env" {
  name                = "${var.app_name}-env"
  resource_group_name = azurerm_resource_group.pulzen-rg.name
  location            = var.location
  infrastructure_subnet_id   = azurerm_subnet.container_subnet.id
}

# Container App with Public HTTPS
resource "azurerm_container_app" "app" {
  name                       = var.app_name
  resource_group_name        = azurerm_resource_group.pulzen-rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode              = "Single"

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