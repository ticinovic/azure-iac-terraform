## Terraform Configuration Files

This directory holds all the Terraform code for the project. I've split the configuration into logical files based on the resources they manage, which is a best practice for Infrastructure as Code (IaC).

### How the Code is Organized

-   **`providers.tf`**: Declares the required Terraform providers (`azurerm`, `random`) and locks in their versions. This prevents unexpected issues by ensuring a consistent deployment environment.

-   **`variables.tf`**: Contains all input variables for the project, like `project_name`, `environment`, and `location`. Each variable has a description and a default value, making the code reusable and easy to customize.

-   **`main.tf`**: This is the main entry point. It sets up the core `azurerm_resource_group` that holds everything else and fetches essential Azure client info needed by other resources.

-   **`network.tf`**: Manages all networking resources. This file creates our secure network boundary, including the `azurerm_virtual_network`, the two specialized subnets (`app_service_subnet` and `endpoint_subnet`), and the `azurerm_network_security_group` for our traffic rules.

-   **`storage.tf`**: Defines the `azurerm_storage_account` and its `azurerm_private_endpoint`. The key security setting `public_network_access_enabled = false` is set here to keep the storage account off the public internet.

-   **`dns.tf`**: Handles the private DNS for the private endpoint. It sets up an `azurerm_private_dns_zone` and links it to the VNet, making sure that requests to the storage account from inside the VNet correctly resolve to its private IP.

-   **`webapp.tf`**: Defines the `azurerm_service_plan` and the `azurerm_linux_web_app`. It also configures the web app's VNet Integration, which is how it sends outbound traffic into our private network to talk to the storage account.

-   **`keyvault.tf`**: Contains the setup for the `azurerm_key_vault`. This file creates the vault, stores a secret, and sets up an access policy that securely grants the web app's Managed Identity permission to read secrets.

-   **`outputs.tf`**: Declares the outputs that will be displayed after a successful deployment, like `resource_group_name` and `web_app_hostname`. This gives you quick access to important details about the new infrastructure.
