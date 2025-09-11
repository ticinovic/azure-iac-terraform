output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "web_app_name" {
  description = "The name of the Web App."
  # Ensure your 'webapp' module outputs the application's name.
  value = module.webapp.name
}
