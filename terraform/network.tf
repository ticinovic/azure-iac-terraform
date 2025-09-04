# terraform/network.tf

# VNet
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# Subnet za App Service VNet Integration
resource "azurerm_subnet" "app_service_subnet" {
  name                 = "snet-appservice"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.app_service_subnet_prefix
  # za Integration subnet ne treba PE policies
}

# Subnet za Private Endpoints (mora imati PE policies disabled)
resource "azurerm_subnet" "endpoint_subnet" {
  name                 = "snet-endpoints"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.endpoint_subnet_prefix

  # novi provider atribut
  private_endpoint_network_policies_enabled = false
}

# NSG - stroga pravila
resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Zatvori sav inbound
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Dozvoli outbound 443 prema PE subnetu (za usluge iza Private Endpointa)
  security_rule {
    name                       = "Allow443ToPE"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_subnet.endpoint_subnet.address_prefixes[0]
  }

  # Zabrani ostali outbound
  security_rule {
    name                       = "DenyAllOutbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Poveži NSG na subnet-e
resource "azurerm_subnet_network_security_group_association" "app_service" {
  subnet_id                 = azurerm_subnet.app_service_subnet.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_subnet_network_security_group_association" "endpoint" {
  subnet_id                 = azurerm_subnet.endpoint_subnet.id
  network_security_group_id = azurerm_network_security_group.main.id
}
