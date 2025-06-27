# Main Terraform configuration para o Redmine AI Reporter
# Otimizado para usar serviços gratuitos do Azure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Random string for unique resource names
resource "random_string" "resource_token" {
  length  = 8
  special = false
  upper   = false
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Local values for resource naming and tags
locals {
  resource_token = lower(random_string.resource_token.result)

  tags = {
    "azd-env-name" = var.environment_name
    "app-name"     = var.app_name
    "project"      = "redmine-ai-reporter"
    "cost-center"  = "development"
    "environment"  = var.environment_name
  }

  resource_names = {
    storage_account  = "redmineai${local.resource_token}st"  # No hífens para Storage Account
    static_web_app   = "${var.resource_prefix}-${local.resource_token}-swa"
    function_app     = "${var.resource_prefix}-${local.resource_token}-func"
    app_service_plan = "${var.resource_prefix}-${local.resource_token}-asp"
    key_vault        = "${var.resource_prefix}-${local.resource_token}-kv"
    app_insights     = "${var.resource_prefix}-${local.resource_token}-ai"
    log_analytics    = "${var.resource_prefix}-${local.resource_token}-log"
    managed_identity = "${var.resource_prefix}-${local.resource_token}-mi"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

# 1. User-Assigned Managed Identity
resource "azurerm_user_assigned_identity" "main" {
  name                = local.resource_names.managed_identity
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

# 2. Log Analytics Workspace (Free tier: 5GB/month)
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.resource_names.log_analytics
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30  # Minimum for free tier
  daily_quota_gb      = 1   # Limit to prevent unexpected charges
  tags                = local.tags
}

# 3. Application Insights
resource "azurerm_application_insights" "main" {
  name                = local.resource_names.app_insights
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  tags                = local.tags
}

# 4. Storage Account (Free tier: 5GB LRS)
resource "azurerm_storage_account" "main" {
  name                     = local.resource_names.storage_account
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"  # Cheapest option
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  # Blob soft delete - free but can consume storage
  blob_properties {
    delete_retention_policy {
      days = 7  # Minimum to avoid extra storage costs
    }
  }

  network_rules {
    default_action = "Allow"
  }

  tags = local.tags
}

# 5. Key Vault (Free tier: 10,000 transactions/month)
resource "azurerm_key_vault" "main" {
  name                = local.resource_names.key_vault
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"  # Free tier

  soft_delete_retention_days = 7   # Minimum allowed
  purge_protection_enabled   = false  # Disable to avoid retention costs

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = local.tags
}

# Key Vault Access Policy for Managed Identity
resource "azurerm_key_vault_access_policy" "managed_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.main.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Key Vault Access Policy for GitHub Actions Service Principal
resource "azurerm_key_vault_access_policy" "github_actions" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

# 6. App Service Plan (Consumption - Free tier)
resource "azurerm_service_plan" "main" {
  name                = local.resource_names.app_service_plan
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Windows"
  sku_name            = "Y1"  # Consumption plan - pay-per-execution, includes free executions
  tags                = local.tags
}

# 7. Function App
resource "azurerm_windows_function_app" "main" {
  name                = local.resource_names.function_app
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key

  https_only = true

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.main.id
    ]
  }

  site_config {
    ftps_state                             = "Disabled"
    minimum_tls_version                    = "1.2"
    application_insights_connection_string = azurerm_application_insights.main.connection_string

    cors {
      allowed_origins     = ["*"]
      support_credentials = false
    }

    application_stack {
      node_version = "~20"
    }
  }

  app_settings = {
    "FUNCTIONS_EXTENSION_VERSION"           = "~4"
    "FUNCTIONS_WORKER_RUNTIME"              = "node"
    "WEBSITE_NODE_DEFAULT_VERSION"          = "~20"
    "WEBSITE_RUN_FROM_PACKAGE"              = "1"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"        = "false"
    "ENABLE_ORYX_BUILD"                     = "false"
    "AzureWebJobsStorage"                   = azurerm_storage_account.main.primary_connection_string
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    "AZURE_CLIENT_ID"                       = azurerm_user_assigned_identity.main.client_id
    "KEY_VAULT_URI"                         = azurerm_key_vault.main.vault_uri
    "AZURE_OPENAI_ENDPOINT"                 = azurerm_cognitive_account.openai.endpoint
    "AZURE_OPENAI_MODEL_DEPLOYMENT"         = azurerm_cognitive_deployment.gpt_model.name
    "AZURE_OPENAI_API_KEY"                  = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.main.name};SecretName=OPENAI-API-KEY)"
  }

  tags = merge(local.tags, {
    "azd-service-name" = "api"
  })

  depends_on = [
    azurerm_storage_account.main,
    azurerm_application_insights.main,
    azurerm_user_assigned_identity.main
  ]
}

# 8. Static Web App (Free tier)
resource "azurerm_static_web_app" "main" {
  name                = local.resource_names.static_web_app
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_tier            = "Free"  # Free tier: 100GB bandwidth, custom domains
  sku_size            = "Free"

  tags = merge(local.tags, {
    "azd-service-name" = "frontend"
  })
}

# 9. Role Assignments

# Storage Blob Data Contributor
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope              = azurerm_storage_account.main.id
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
  principal_id       = azurerm_user_assigned_identity.main.principal_id
}

# Storage Queue Data Contributor
resource "azurerm_role_assignment" "storage_queue_data_contributor" {
  scope              = azurerm_storage_account.main.id
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/974c5e8b-45b9-4653-ba55-5f855dd0fb88"
  principal_id       = azurerm_user_assigned_identity.main.principal_id
}

# Storage Table Data Contributor
resource "azurerm_role_assignment" "storage_table_data_contributor" {
  scope              = azurerm_storage_account.main.id
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3"
  principal_id       = azurerm_user_assigned_identity.main.principal_id
}

# Monitoring Metrics Publisher
resource "azurerm_role_assignment" "monitoring_metrics_publisher" {
  scope              = azurerm_application_insights.main.id
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/3913510d-42f4-4e42-8a64-420c390055eb"
  principal_id       = azurerm_user_assigned_identity.main.principal_id
}

# Azure OpenAI Service
resource "azurerm_cognitive_account" "openai" {
  name                = "redmine-ai-${random_string.resource_token.result}-openai"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "OpenAI"

  sku_name = "S0"

  custom_subdomain_name = "redmine-ai-${random_string.resource_token.result}-openai"
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

# OpenAI Deployment - GPT-4o-mini (mais barato)
resource "azurerm_cognitive_deployment" "gpt_model" {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-07-18"
  }

  scale {
    type = "Standard"
  }

  depends_on = [azurerm_cognitive_account.openai]
}

# Role assignment for Managed Identity to access OpenAI
resource "azurerm_role_assignment" "openai_user" {
  scope              = azurerm_cognitive_account.openai.id
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/5e0bd9bd-7b93-4f28-af87-19fc36ad61bd"
  principal_id       = azurerm_user_assigned_identity.main.principal_id
}

# Add OpenAI secrets to Key Vault
resource "azurerm_key_vault_secret" "openai_endpoint" {
  name         = "AZURE-OPENAI-ENDPOINT"
  value        = azurerm_cognitive_account.openai.endpoint
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_key_vault_access_policy.managed_identity,
    azurerm_key_vault_access_policy.github_actions
  ]
}

resource "azurerm_key_vault_secret" "openai_model" {
  name         = "AZURE-OPENAI-MODEL"
  value        = azurerm_cognitive_deployment.gpt_model.name
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_key_vault_access_policy.managed_identity,
    azurerm_key_vault_access_policy.github_actions
  ]
}
