output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "app_service_subnet_id" {
  value = azurerm_subnet.app_service.id
}

output "endpoint_subnet_id" {
  value = azurerm_subnet.endpoint.id
}
