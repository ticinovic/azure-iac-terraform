terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

# Top-level data source (NOT inside provider)
data "azurerm_client_config" "current" {}

# Short suffix for globally-unique names (storage/kv)
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# Compose/sanitize names
locals {
  proj_slim = lower(regexreplace(var.project_name, "[^a-z0-9]", ""))
  env_slim  = lower(regexreplace(var.environment, "[^a-z0-9]", ""))

  # Resource Group name (allow override)
  rg_name = coalesce(var.resource_group_name, "rg-${var.project_name}-${var.environment}")

  # Storage: 3-24 lower alphanum only
  sa_composed = "st${local.proj_slim}${local.env_slim}${random_string.suffix.result}"
  sa_name     = coalesce(var.storage_account_name, substr(local.sa_composed, 0, 24))

  # Key Vault: keep within length limits
  kv_composed = "kv-${local.proj_slim}-${local.env_slim}-${random_string.suffix.result}"
  kv_name     = coalesce(var.key_vault_name, substr(local.kv_composed, 0, 24))
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

# ─────────────────────────────────────────────────────────
# Modules
# ─────────────────────────────────────────────────────────

module "network" {
  source                  = "./modules/network"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  project_name            = var.project_name
  environment             = var.environment
  address_space           = var.address_space
  app_service_subnet_cidr = var.app_service_subnet_cidr
  endpoint_subnet_cidr    = var.endpoint_subnet_cidr
  tags                    = var.tags
}

module "webapp" {
  source                = "./modules/webapp"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  project_name          = var.project_name
  environment           = var.environment
  runtime_stack         = var.runtime_stack
  app_service_sku       = var.app_service_sku
  app_service_subnet_id = module.network.app_service_subnet_id
  tags                  = var.tags
}

module "storage" {
  source               = "./modules/storage"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  project_name         = var.project_name
  environment          = var.environment
  storage_account_name = local.sa_name
  vnet_id              = module.network.vnet_id
  endpoint_subnet_id   = module.network.endpoint_subnet_id
  tags                 = var.tags
}

module "keyvault" {
  source              = "./modules/keyvault"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  key_vault_name      = local.kv_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  vnet_id             = module.network.vnet_id
  endpoint_subnet_id  = module.network.endpoint_subnet_id
  webapp_principal_id = module.webapp.principal_id
  tags                = var.tags
}
