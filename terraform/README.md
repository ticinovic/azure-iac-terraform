## Terraform Configuration Files

This directory contains all **Terraform code** for the project. The configuration is split into logical files based on the resources they manage, following **Infrastructure as Code (IaC) best practices**.

### **Project Structure**

The project is organized into **Terraform configuration files** and **workflow files**:

- **`terraform/main.tf`**  
    *It defines resource group*

- **`terraform/variables.tf`**  
    *Contains input variables (project name, environment, location, etc.) with default values for easy customization.*

- **`terraform/network.tf`**  
    *Sets up networking components: the VNet, subnets (with proper delegation and policies), and the NSG with its security rules.*

- **`terraform/storage.tf`**  
    *Creates the Storage Account (`public_network_access_enabled = false`) and a Private Endpoint in the endpoint subnet for secure access.*

- **`terraform/dns.tf`**  
    *Configures a Private DNS Zone for the storage account’s private endpoint and links it to the VNet for internal name resolution.*

- **`terraform/webapp.tf`**  
    *Deploys the App Service Plan and Web App. Enables VNet Integration (connecting the Web App to the app_service_subnet) and sets Access Restrictions to allow only traffic from the VNet. Also enables a system-managed identity for the Web App.*

- **`terraform/keyvault.tf`** *(Optional)*  
    *Deploys an Azure Key Vault with no public access and a Private Endpoint. Includes an access policy so the Web App’s managed identity can read secrets from the vault.*

- **`terraform/outputs.tf`**  
    *Defines output values (e.g., the resource group name and the Web App’s URL) that Terraform will show after deployment.*

- **`.github/workflows/deploy.yml`**  
    *GitHub Actions workflow to plan and apply the Terraform deployment. Runs on pushes to the main branch or can be triggered manually. Performs Terraform formatting checks, validation, plans the changes, and applies them if on the main branch (or when manually run).*

- **`.github/workflows/destroy.yml`**  
    *GitHub Actions workflow to destroy all Terraform-managed resources. This is a manual workflow (triggered via the Actions tab) used for teardown/rollback, requiring a confirmation input (`destroy`) before it runs.*

---
