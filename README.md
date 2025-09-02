# azure-iac-terraform - repo
# Practical Exam Task: Deploy Azure Infrastructure Using Terraform and GitHub Actions

 Hello, before we start, you're in repository azure-iac-terraform, which is initiated by Practical Exam Task.
 
 This project stands as understanding of mine from DevOps boot camp acadamy which took part at Summer 2025.
 
 # Secure Azure Infrastructure with Terraform and GitHub Actions

Here you'll find a production-ready Terraform setup for deploying a secure web app in Azure. I've designed the whole thing to be private by default—that means no public IPs and all network traffic stays inside an internal Virtual Network.

The entire deployment process is automated with a CI/CD pipeline using GitHub Actions.

## Project Overview

I've configured this project to spin up the following Azure resources, all with security in mind:

  - **Azure Resource Group**: A logical container for all the resources.
  - **Azure Virtual Network (VNet)**: The primary network boundary, isolating everything from the public internet.
  - **Two Azure Subnets**:
      - An `app_service_subnet` delegated for App Service VNet Integration.
      - An `endpoint_subnet` for hosting Private Endpoints.
  - **Azure Storage Account**: Configured to block all public network access.
  - **Azure Private Endpoint**: Gives the Storage Account a private IP address inside our VNet.
  - **Azure Private DNS Zone**: For seamless DNS resolution to the private endpoint.
  - **Azure App Service Plan**: Defines the compute resources for our web app.
  - **Azure Web App**: A Linux-based web app integrated with the VNet for secure outbound traffic.
  - **Azure Network Security Group (NSG)**: Filters traffic between subnets, enforcing a least-privilege access model.
  - **(Bonus) Azure Key Vault**: Securely manages application secrets using Managed Identity.

## Architecture Diagram

subgraph "Azure Cloud"
    style AzureCloud fill:#f0f8ff,stroke:#0078d4,stroke-width:2px

    subgraph VNet [Azure Virtual Network (10.0.0.0/16)]
        direction LR
        style VNet fill:#e3f2fd,stroke:#0078d4,stroke-width:1px,stroke-dasharray: 5 5

        subgraph AppSubnet
            WebApp
        end

        subgraph EndpointSubnet
            PE[<img src='[https://raw.githubusercontent.com/microsoft/az-icon-collection/main/azure-symbol-original/Private%20Link.svg](https://raw.githubusercontent.com/microsoft/az-icon-collection/main/azure-symbol-original/Private%20Link.svg)' width='40' height='40' /><br/>Private Endpoint]
        end

        NSG
    end

    subgraph PaaS
        direction TB
        SA
        PDNS
    end
end

%% Define Connections & Data Flow
GHA -- "Deploys & Manages" --> VNet
GHA -- "Deploys & Manages" --> PaaS

WebApp -- "Outbound via VNet Integration" --> PE
PE -.->|Private IP within VNet| SA

PDNS -. "Resolves FQDN to Private IP".-> VNet
NSG -- "Applies Rules" --> AppSubnet
NSG -- "Applies Rules" --> EndpointSubnet

%% Styling
classDef default fill:#ffffff,stroke:#333,stroke-width:1px;
class GHA,WebApp,PE,NSG,SA,PDNS default;
## Prerequisites

You'll need a few things before you get started:

1.  An active Azure Subscription.
2.  A GitHub account.
3.  [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed locally.

## Setup Instructions

Ready to deploy? Just follow these steps:

1.  **Copy this Repository**: Create a copy of this repository in your own GitHub account.

2.  **Create an Azure Service Principal**: This is the identity GitHub Actions will use to authenticate to Azure.

      - Log in to Azure: `az login`
      - Set your subscription: `az account set --subscription "<Your-Subscription-ID>"`
      - Create the Service Principal with the 'Contributor' role:
        ```bash
        az ad sp create-for-rbac --name "github-actions-terraform-sp" --role "Contributor" --scopes "/subscriptions/<Your-Subscription-ID>"
        ```
      - The command will output a JSON object. **Copy the `appId`, `password`, and `tenant` values.**

3.  **Configure GitHub Secrets**: In your copied repository, go to `Settings` \> `Secrets and variables` \> `Actions` and create these four repository secrets:

      - `ARM_CLIENT_ID`: The `appId` from the previous step.
      - `ARM_CLIENT_SECRET`: The `password` from the previous step.
      - `ARM_SUBSCRIPTION_ID`: Your Azure Subscription ID.
      - `ARM_TENANT_ID`: The `tenant` from the previous step.

## How to Run the Workflow

Deploying changes is simple, thanks to an automated GitOps workflow:

1.  **Create a Pull Request**: Create a new branch, make any changes you want to the Terraform code, and open a pull request against the `main` branch.
2.  **Review the Plan**: GitHub Actions will automatically trigger a `terraform plan`. A comment will be posted on your pull request showing the execution plan. Review it carefully to see what's going to change.
3.  **Merge to Deploy**: Once you're happy with the plan, merge the pull request into `main`. This triggers the workflow again, but this time it will run `terraform apply` to deploy the infrastructure to Azure.

## Expected Output

After the workflow runs successfully on the `main` branch, you'll have a new set of Azure resources. You can find the specific output values, like the ones below, in the "Outputs" tab of the GitHub Actions run:

  - **`resource_group_name`**: The name of the created Azure Resource Group.
  - **`web_app_hostname`**: The default hostname of the deployed Web App (e.g., `app-projectname-env-xxxx.azurewebsites.net`). Note that this hostname is only accessible from within the private virtual network.

## Security Hardening Details

Here’s a breakdown of the specific security measures I've implemented:

  - **Network Isolation**: All resources are deployed inside a private VNet with no internet gateway.
  - **No Public IPs**: No public IP addresses are provisioned for any resource.
  - **Storage Account Hardening**: Public network access is explicitly disabled (`public_network_access_enabled = false`).
  - **Private Endpoint**: The Storage Account is made accessible within the VNet via a Private Endpoint.
  - **Web App VNet Integration**: The Web App's outbound traffic is routed into the private VNet, allowing it to access the Storage Account's private endpoint.
  - **NSG Traffic Filtering**: A Network Security Group is configured to deny all traffic by default and only allow necessary communication between the application and endpoint subnets on port 443.
	
## (Bonus) How to Run the Destroy Workflow

I've also included a separate, manual workflow to tear down all the infrastructure. **Heads up**: this is a destructive action, so please use it with caution.

1.  Navigate to the **Actions** tab in your GitHub repository.
2.  In the left sidebar, click on the **Terraform Destroy** workflow.
3.  Click the **Run workflow** dropdown button.
4.  In the text box, type the word `destroy` to confirm.
5.  Click the green **Run workflow** button.
