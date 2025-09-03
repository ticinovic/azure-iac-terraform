# terraform/webapp.tf

# Create an App Service Plan to define the compute resources for the Web App
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "P1v2" # A Premium SKU is required for VNet integration
  tags                = var.tags
}

# Create the Linux Web App
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.project_name}-${var.environment}-${random_string.storage_suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  # This setting enables the VNet Integration feature for outbound traffic.
  virtual_network_subnet_id = azurerm_subnet.app_service_subnet.id

  # Enable System-Assigned Managed Identity
  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_VNET_ROUTE_ALL" = "1"
    "WEBSITE_DNS_SERVER"     = "168.63.129.16"
    "MyWebAppSecret"         = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.example.id})"
  }

  site_config {
    application_stack {
      # This example uses a simple static site, so no specific stack is needed.
    }
    always_on = true
  }

  tags = var.tags
}

# Deploy a sample HTML file to the web app
resource "azurerm_app_service_source_control" "main" {
  app_id   = azurerm_linux_web_app.main.id
  repo_url = "https://github.com/Azure-Samples/html-docs-hello-world"
  branch   = "master"
}