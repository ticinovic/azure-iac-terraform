# Private DNS zone for Storage (Blob)
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name  # fixed: rg, not main
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_link" {
  name                  = "pdnszlink-blob-${local.base_name}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}
