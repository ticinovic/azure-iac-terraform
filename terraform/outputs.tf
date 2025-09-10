output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "web_app_hostname" {
  description = "Default hostname of the deployed Web App"
  value       = module.webapp.default_hostname
}
