# Creates the App Service Plan
resource "azurerm_service_plan" "main" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

# Creates the Linux Web App, configured for Docker
resource "azurerm_linux_web_app" "main" {
  name                = var.web_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = var.tags

  # Keep the System-Assigned Identity
  identity { type = "SystemAssigned" }

  site_config {
    # ADDED: This block now configures the app to run a specific Docker image.
    # The previous Node.js 'application_stack' has been replaced.
    application_stack {
      docker_image_name = "${var.acr_login_server}/secureapp:latest"
    }

    # Keep your existing security settings
    ip_restriction_default_action     = "Deny"
    scm_ip_restriction_default_action = "Deny"
  }

  # ADDED: These settings provide the credentials for your private ACR.
  # The previous 'app_settings' have been replaced.
  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${var.acr_login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = var.acr_admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = var.acr_admin_password
  }
}

# Keep the VNet integration resource
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = var.app_service_subnet_id
}