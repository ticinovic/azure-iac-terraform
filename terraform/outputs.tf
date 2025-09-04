# terraform/outputs.tf

output "resource_group_name" {
  description = "The name of the created Azure Resource Group."
  value       = azurerm_resource_group.main.name
}

output "web_app_hostname" {
  description = "The default hostname of the deployed Web App."
  value       = azurerm_linux_web_app.main.default_hostname
}
