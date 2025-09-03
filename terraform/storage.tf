# terraform/storage.tf

# Create a globally unique name for the storage account
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create the Azure Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "st${var.project_name}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # CRITICAL: This setting disables all access from the public internet.
  public_network_access_enabled = false

  tags = var.tags
}

# Create a Private Endpoint to provide access to the storage account from within the VNet
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-storage-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  # This block links the endpoint to the private DNS zone,
  # enabling automatic A record creation.
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.main.id]
  }
}