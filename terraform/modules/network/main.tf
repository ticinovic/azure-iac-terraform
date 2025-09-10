# modules/network/main.tf

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# App Service delegated subnet
resource "azurerm_subnet" "app_service" {
  name                 = "snet-appsvc-${var.project_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.app_service_subnet_cidr]

  delegation {
    name = "appsvc-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Endpoint subnet (for Private Endpoints)
resource "azurerm_subnet" "endpoint" {
  name                 = "snet-endpoints-${var.project_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.endpoint_subnet_cidr]

  # DEPRECATION FIX: use string property instead of *_enabled = true/false
  private_endpoint_network_policies = "Enabled" # or "Disabled" if you want to disable them
}

# Associate NSG to subnets (adjust/add rules in this NSG as you need)
resource "azurerm_subnet_network_security_group_association" "appsvc" {
  subnet_id                 = azurerm_subnet.app_service.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_subnet_network_security_group_association" "endpoint" {
  subnet_id                 = azurerm_subnet.endpoint.id
  network_security_group_id = azurerm_network_security_group.main.id
}
