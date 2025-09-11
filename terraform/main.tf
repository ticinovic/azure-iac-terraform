terraform {
  required_version = ">= 1.4.0"
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

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# NETWORK
module "network" {
  source                  = "./modules/network"
  resource_group_name     = azurerm_resource_group.main.name
  location                = var.location
  vnet_name               = var.vnet_name
  app_service_subnet_cidr = var.app_service_subnet_cidr
  endpoint_subnet_cidr    = var.endpoint_subnet_cidr
  nsg_name                = var.nsg_name
  tags                    = var.tags
}

module "webapp" {
  source = "./modules/webapp"

  web_app_name          = var.web_app_name
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  service_plan_name     = var.service_plan_name
  app_service_sku       = var.app_service_sku
  app_service_subnet_id = module.network.app_service_subnet_id
  tags                  = var.tags

  acr_login_server   = azurerm_container_registry.acr.login_server
  acr_admin_username = azurerm_container_registry.acr.admin_username
  acr_admin_password = azurerm_container_registry.acr.admin_password
}

# STORAGE
module "storage" {
  source               = "./modules/storage"
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  storage_account_name = var.storage_account_name
  vnet_id              = module.network.vnet_id
  endpoint_subnet_id   = module.network.endpoint_subnet_id
  tags                 = var.tags
}

module "keyvault" {
  source              = "./modules/keyvault"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  key_vault_name      = var.key_vault_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  vnet_id             = module.network.vnet_id
  endpoint_subnet_id  = module.network.endpoint_subnet_id
  webapp_principal_id = module.webapp.principal_id
  tags                = var.tags
}
