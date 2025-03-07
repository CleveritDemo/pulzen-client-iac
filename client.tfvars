cloud_provider = "gcp"

app_name        = "client-app"
container_image = "pulzen/gateway:latest"
db_name        = "clientdb"
location        = "us-central1"

# Azure
resource_group  = "your-resource-group"

# GCP
project_id      = "your-gcp-project-id"


env_vars = {
  ENVIRONMENT   = "production"
  API_KEY       = "your-api-key"
  FEATURE_FLAG  = "true"
}
