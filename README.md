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

In your GitHub repository, go to **Settings > Secrets and variables > Actions**, and add:

- `ARM_CLIENT_ID` – set to `appId`
- `ARM_CLIENT_SECRET` – set to `password`
- `ARM_TENANT_ID` – set to `tenant`
- `ARM_SUBSCRIPTION_ID` – set to your Subscription ID

> These secrets are used by Terraform and the Azure login Action for authentication.

---

### **3. Review Terraform Variables (Optional)**

Open `terraform/variables.tf` to review or adjust default values (e.g., location, storage account name, key vault name).

---

## **Deployment (GitHub Actions Workflow)**

Once secrets are configured, deploy infrastructure using GitHub Actions:

- **Manual Trigger:** Go to the **Actions** tab, select **Terraform Deploy**, and click **Run workflow**.
- **Git Push Trigger:** Any push to `main` starts the workflow. Pull requests run in **plan-only** mode and comment the Terraform plan for review.

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

## **(Bonus) Destroy Workflow – Tearing Down Resources**

To destroy all Azure resources:

1. Go to **Actions** tab.
2. Select **Terraform Destroy**.
3. Click **Run workflow** and confirm by typing `destroy`.

> **Warning:** This will **permanently delete** the infrastructure.

---

