# terraform/storage.tf

# Storage Account (privatno)
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  # OVO OSTAVI — gasi javni pristup na mrežnoj razini
  public_network_access_enabled = false

  # (opcionalno, radi jasnoće)
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# Private Endpoint za BLOB + veza na postojeću private DNS zonu iz dns.tf
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_service_connection {
    name                           = "psc-storage-${var.project_name}-${var.environment}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.main.id] # iz dns.tf
  }

  tags = var.tags
}