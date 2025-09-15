# **Secure Azure Infrastructure with Terraform and GitHub Actions**

This repository contains a **Terraform-based solution** for deploying a **secure Azure infrastructure**. It was created as a practical exam project (**DevOps Bootcamp, Summer 2025**). It demonstrates how to:

- **Provision Azure resources securely using Terraform (Infrastructure as Code)**
- **Automate provisioning with GitHub Actions (CI/CD pipeline)**
- **Ensure all resources are private, with no public internet access**

---

## **Project Overview**

The Terraform configuration deploys the following resources **with security in mind**:

- **Azure Resource Group** – logical container for all resources.
- **Azure Virtual Network (VNet)** – isolated network boundary for all components (**no direct internet exposure**).
- **Two Subnets within the VNet:**
  - `app_service_subnet` – delegated for App Service VNet integration.
  - `endpoint_subnet` – for hosting Private Endpoints.
- **Azure Storage Account** – public access **disabled**, accessible only via private network.
- **Azure Private Endpoint** – gives the Storage Account a private IP in the endpoint subnet (**internal access only**).
- **Azure Private DNS Zone** – DNS resolution for the storage account’s private endpoint within the VNet.
- **Azure App Service Plan** – hosts the web application (**Linux plan with VNet integration**).
- **Azure Web App** – Linux web app (**Node.js runtime**) with VNet Integration for outbound traffic and **access restrictions** that block all public incoming requests (**internal only**).
- **Azure Network Security Group (NSG)** – attached to subnets to enforce strict traffic rules (**deny-all by default, only allow necessary internal traffic**).
- **(Optional) Azure Key Vault** – secure secret store with private endpoint; the Web App’s managed identity is granted access to retrieve secrets (**no public exposure of keys or credentials**).

> **Note:** The Web App can host a simple HTML page (e.g., “Hello World” test page) to verify the deployment. **Due to network restrictions, it is only reachable from within the private network.**

---

## **Prerequisites**

Before you begin, ensure you have:

- **Azure Subscription** – active Azure account with a subscription.
- **GitHub Account & Repository** – code should reside in a GitHub repository (fork this repo if needed).
- **Azure CLI** – installed locally to set up Azure credentials (login and create a Service Principal).

---

## **Setup Instructions**

### **1. Create Azure Service Principal (for GitHub Actions)**

Login to Azure and select your subscription:

```sh
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

Create the Service Principal:

```sh
az ad sp create-for-rbac --name "github-actions-terraform-sp" --role "Contributor" \
  --scopes "/subscriptions/<YOUR_SUBSCRIPTION_ID>"
```

**Copy these values from the output:**

- `appId` (**Client ID**)
- `password` (**Client Secret**)
- `tenant` (**Tenant ID**)
- **Subscription ID**

---

### **2. Configure GitHub Secrets**

In your GitHub repository, go to **Settings > Secrets and variables > Actions > Environment secrets > Create new environment (if don't exists) > Create environment "production"**, and add:

- `ARM_CLIENT_ID` – set to `appId`
- `ARM_CLIENT_SECRET` – set to `password`
- `ARM_TENANT_ID` – set to `tenant`
- `ARM_SUBSCRIPTION_ID` – set to your Subscription ID

> These secrets are used by Terraform and the Azure login Action for authentication.

---

### **3. Terraform Folder Structure**

The `terraform` directory contains all Infrastructure as Code files:

```
terraform/
├── main.tf                # Main Terraform configuration (resource definitions)
├── variables.tf           # Input variables for customization
├── outputs.tf             # Output values (resource names, endpoints, etc.)
├── providers.tf           # Provider configuration (Azure setup)
├── terraform.tfvars       # Variable values for your environment
├── modules/               # Custom modules for reusable components
│   ├── network/
│   │   ├── main.tf        # VNet, subnets, NSG definitions
│   │   ├── variables.tf   # Network module input variables
│   │   ├── outputs.tf     # Network module outputs
│   ├── storage/
│   │   ├── main.tf        # Storage Account, Private Endpoint
│   │   ├── variables.tf   # Storage module input variables
│   │   ├── outputs.tf     # Storage module outputs
│   ├── app_service/
│   │   ├── main.tf        # App Service Plan, Web App, VNet integration
│   │   ├── variables.tf   # App Service module input variables
│   │   ├── outputs.tf     # App Service module outputs
│   └── key_vault/         # Key Vault module
│       ├── main.tf        # Key Vault, Private Endpoint
│       ├── variables.tf   # Key Vault module input variables
│       ├── outputs.tf     # Key Vault module outputs
├── app/                   # Application source code (Node.js web app)
│   └── Dockerfile         # Dockerfile for building the web app container
├── www/                   # Static web content (HTML, CSS, JS)
│   ├── index.html         # Main HTML page (e.g., "Hello World")
└── README.md              # Documentation for the whole repository
```

> **Tip:** Each file serves a specific purpose. For example, `main.tf` defines resources, while `variables.tf` and `terraform.tfvars` allow easy customization.  
You can customize deployment settings by editing the `terraform/terraform.tfvars` file. This file lets you override variable defaults (e.g., resource names, location, environment tags) for your environment.

---

## **Deployment (GitHub Actions Workflow)**

Once secrets are configured, deploy infrastructure using GitHub Actions:

  - **Manual Trigger:** Go to the **Actions** tab, select **Terraform Deploy**, and click **Run workflow**.
  - The workflow requires **two approvals**:
    1. **Build and Deploy Infrastructure** – approves provisioning Azure resources.
    2. **Build and Deploy Application** – approves deployment of the application to the Web App.

- **Git Push Trigger:** Any push to `main` starts the workflow, but deployment requires manual approval. Pull requests run in **plan-only** mode and comment the Terraform plan for review.


**After deployment, check Outputs for:**

- `resource_group_name` – name of the Azure Resource Group.
- `web_app_hostname` – default hostname of the Web App (**private URL**).

---

## **Security Measures**

- **Private Networking:** All resources are inside a private VNet. **No public IPs** assigned.
- **No Public Access Endpoints:** Storage Account and Key Vault have `public_network_access_enabled = false`.
- **VNet Integration for Web App:** Outbound traffic goes through the VNet; uses **HTTPS-only** and **Managed Identity**.
- **Network Security Group (NSG):** **Deny-all by default**; only specific internal traffic allowed.
- **Secure Secret Management (Key Vault):** Only accessible via private endpoint; managed identity for secret access.

---

## **Destroy Workflow – Tearing Down Resources**

To destroy all Azure resources:

1. Go to **Actions** tab.
2. Select **Terraform Destroy (Rollback)**.
3. Click **Run workflow** and confirm by typing `destroy`.

> **Warning:** This will **permanently delete** the infrastructure.

---

