# terraform/dns.tf

# Create a Private DNS Zone for the blob storage private link
# The name is a standard, required format for Azure Storage blob endpoints.
resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Link the Private DNS Zone to our Virtual Network
# This allows resources within the VNet to resolve records in this zone.
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "pdnsz-vnet-link-${var.project_name}"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
}