# modules/webapp/outputs.tf

output "name" {
  description = "The name of the Linux Web App."
  value       = azurerm_linux_web_app.main.name
}

output "default_hostname" {
  description = "The default hostname of the Linux Web App."
  value       = azurerm_linux_web_app.main.default_hostname
}

output "principal_id" {
  description = "The principal ID of the Web App's System-Assigned Managed Identity."
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}