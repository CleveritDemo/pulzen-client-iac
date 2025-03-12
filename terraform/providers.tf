terraform {
  required_version = ">= 1.3"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.location
}

provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # Only configure Azure provider if subscription_id is set
  subscription_id = var.azure_subscription_id != "" ? var.azure_subscription_id : null
}
