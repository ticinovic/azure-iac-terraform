# terraform/keyvault.tf (Bonus)

# Create an Azure Key Vault
resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.project_name}-${random_string.storage_suffix.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Set to true for production

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Store a sample secret in the Key Vault
resource "azurerm_key_vault_secret" "example" {
  name         = "WebAppSecret"
  value        = "ThisIsAHighlySecureValue"
  key_vault_id = azurerm_key_vault.main.id
}

# Grant the Web App's Managed Identity access to the Key Vault secrets
resource "azurerm_key_vault_access_policy" "webapp" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  # FIX: The identity block is a list, so we must index it with 
  object_id = azurerm_linux_web_app.main.identity.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}