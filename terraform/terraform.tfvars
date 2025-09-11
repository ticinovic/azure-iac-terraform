# General
project_name        = "secureapp"
environment         = "dev"
location            = "westeurope"
resource_group_name = "rg-secureapp-dev"

# Networking
vnet_name               = "vnet-secureapp-dev"
nsg_name                = "nsg-secureapp-dev"
app_service_subnet_cidr = "10.10.1.0/24"
endpoint_subnet_cidr    = "10.10.2.0/24"

# Web App
service_plan_name = "asp-secureapp-dev"
app_service_sku   = "P1v2"
web_app_name      = "app-secureapp-dev"

# Storage
storage_account_name = "stsecureappdev1234" # must be 3-24 chars, lowercase alphanum

# Key Vault
key_vault_name = "kv-secureapp-dev"

# Tags
tags = {
  environment = "dev"
  project     = "secureapp"
}
# Azure Container Registry (ACR)
acr_name = "acrsecureappdev123"
