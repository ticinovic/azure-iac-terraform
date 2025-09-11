resource "azurerm_container_registry" "acr" {
  name                = var.acr_name # e.g. "acrsecureappdev"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true # simple pipeline auth
  tags                = var.tags
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
