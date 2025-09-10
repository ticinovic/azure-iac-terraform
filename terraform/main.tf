terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

# Resource Group (keep RG in root for clarity)
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ── Network (VNet, subnets, NSG)
module "network" {
  source                    = "./modules/network"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  project_name              = var.project_name
  environment               = var.environment
  address_space             = var.address_space
  app_service_subnet_cidr   = var.app_service_subnet_cidr
  endpoint_subnet_cidr      = var.endpoint_subnet_cidr
  tags                      = var.tags
}

# ── Web App (Plan + App Service, VNet Integration)
module "webapp" {
  source                    = "./modules/webapp"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  project_name              = var.project_name
  environment               = var.environment
  runtime_stack             = var.runtime_stack
  app_service_sku           = var.app_service_sku
  app_service_subnet_id     = module.network.app_service_subnet_id
  tags                      = var.tags
}

# ── Storage (Account + Private Endpoint + Private DNS)
module "storage" {
  source                    = "./modules/storage"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  project_name              = var.project_name
  environment               = var.environment
  storage_account_name      = var.storage_account_name
  vnet_id                   = module.network.vnet_id
  endpoint_subnet_id        = module.network.endpoint_subnet_id
  tags                      = var.tags
}

# ── Key Vault (Private only + PE + Access Policy for Web App MI)
module "keyvault" {
  source                    = "./modules/keyvault"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  project_name              = var.project_name
  environment               = var.environment
  key_vault_name            = var.key_vault_name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  vnet_id                   = module.network.vnet_id
  endpoint_subnet_id        = module.network.endpoint_subnet_id
  webapp_principal_id       = module.webapp.principal_id
  tags                      = var.tags
}
