# terraform/network.tf

# Create the Virtual Network to serve as the private network boundary
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Create a dedicated subnet for the App Service VNet Integration
# This subnet must be delegated to Microsoft.Web/serverFarms
resource "azurerm_subnet" "app_service_subnet" {
  name                 = "snet-appservice"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Create a dedicated subnet for Private Endpoints
# This subnet must have private endpoint network policies disabled
resource "azurerm_subnet" "endpoint_subnet" {
  name                 = "snet-endpoints"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

  private_endpoint_network_policies_enabled = false
}

# Create a Network Security Group to control traffic within the VNet
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  security_rule {
    name                       = "AllowAppToEndpointHTTPS"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = azurerm_subnet.app_service_subnet.address_prefix
    destination_address_prefix = azurerm_subnet.endpoint_subnet.address_prefix
  }

  security_rule {
    name                       = "DenyAllOtherAppOutbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.app_service_subnet.address_prefix
    destination_address_prefix = "*"
  }
}

# Associate the NSG with the App Service subnet
resource "azurerm_subnet_network_security_group_association" "app_service" {
  subnet_id                 = azurerm_subnet.app_service_subnet.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Associate the NSG with the Endpoint subnet
resource "azurerm_subnet_network_security_group_association" "endpoint" {
  subnet_id                 = azurerm_subnet.endpoint_subnet.id
  network_security_group_id = azurerm_network_security_group.main.id
}