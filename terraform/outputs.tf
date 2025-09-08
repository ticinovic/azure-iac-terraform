output "resource_group_name" {
  description = "Ime RG-a."
  value       = azurerm_resource_group.rg.name
}

output "web_app_hostname" {
  description = "Default hostname Web App-a."
  value       = azurerm_linux_web_app.app.default_hostname
}

output "web_app_name" {
  description = "Naziv Web App-a."
  value       = azurerm_linux_web_app.app.name
}
