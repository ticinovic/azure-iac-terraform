resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  tags = var.tags
}

resource "azurerm_private_dns_zone" "sa" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa" {
  name                  = "pdnsz-sa-link-${var.project_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sa.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_endpoint" "sa" {
  name                = "pe-sa-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.endpoint_subnet_id

  private_service_connection {
    name                           = "psc-sa-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa.id]
  }

  tags = var.tags
}
