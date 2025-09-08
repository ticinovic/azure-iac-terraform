# Unikatno ime za storage ako nije zadano
resource "random_string" "st_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  storage_account_name = var.storage_account_name != null ? var.storage_account_name : replace("st${var.project_name}${var.environment}${random_string.st_suffix.result}", "/[^a-z0-9]/", "")
}

resource "azurerm_storage_account" "sa" {
  name                              = substr(local.storage_account_name, 0, 24)
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = azurerm_resource_group.rg.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"

  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = false

  public_network_access_enabled     = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# Private DNS zona za Blob PE
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_link" {
  name                  = "pdnszlink-blob-${local.base_name}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# Private Endpoint za Blob
resource "azurerm_private_endpoint" "sa_blob_pe" {
  name                = "pe-blob-${local.base_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-blob-${local.base_name}"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdzg-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}
