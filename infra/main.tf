# ========================================
# TERRAFORM CONFIGURATION - FREE TIER ONLY
# ========================================

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

provider "azurerm" {
  features {
    # Proteção extra contra remoção acidental
    key_vault {
      purge_soft_delete_on_destroy    = false
      purge_soft_deleted_keys_on_destroy = false
    }
    cognitive_account {
      purge_soft_delete_on_destroy = false
    }
  }
}

# ========================================
# DATA SOURCES
# ========================================

data "azurerm_client_config" "current" {}

# ========================================
# LOCALS E NAMING
# ========================================
# LOCALS E CONFIGURAÇÕES
# ========================================

locals {
  # Tags padrão
  tags = {
    Environment = "dev"
    Project     = "redmine-ai-reporter"
    ManagedBy   = "terraform"
    CostCenter  = "free-tier"
  }
  
  # Nomes dos recursos - URLs amigáveis e consistentes
  resource_names = {
    resource_group   = var.resource_group_name
    app_insights     = "redmine-ai-reporter-ai"
    log_analytics    = "redmine-ai-reporter-log"
    storage_account  = "redmineaireporterst"  # max 24 chars, no hyphens
    key_vault        = "redmine-ai-reporter-kv"
    managed_identity = "redmine-ai-reporter-mi"
    app_service_plan = "redmine-ai-reporter-asp"
    function_app     = "redmine-ai-reporter-func"
    static_web_app   = "redmine-ai-reporter-swa"
    openai_account   = "redmine-ai-reporter-openai"
  }
}

# ========================================
# 1. RESOURCE GROUP
# ========================================

resource "azurerm_resource_group" "main" {
  name     = local.resource_names.resource_group
  location = var.location
  tags     = local.tags
  
  # Proteção contra remoção acidental
  lifecycle {
    prevent_destroy = true
  }
}

# ========================================
# 2. LOG ANALYTICS (FREE TIER)
# ========================================

resource "azurerm_log_analytics_workspace" "main" {
  name                = local.resource_names.log_analytics
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30    # FREE: até 31 dias
  daily_quota_gb      = 0.5   # FREE: até 5GB/dia
  tags                = local.tags
  
  # Proteção contra perda de logs
  lifecycle {
    prevent_destroy = true
  }
}

# ========================================
# 3. APPLICATION INSIGHTS (FREE)
# ========================================

resource "azurerm_application_insights" "main" {
  name                = local.resource_names.app_insights
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  sampling_percentage = 100  # FREE: até 1GB/mês
  tags                = local.tags
  
  # Proteção contra perda de telemetria
  lifecycle {
    prevent_destroy = true
  }
}

# ========================================
# 4. STORAGE ACCOUNT (FREE TIER)
# ========================================

resource "azurerm_storage_account" "main" {
  name                     = local.resource_names.storage_account
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"        # FREE: Local Redundant Storage
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  
  # Configurações de segurança
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  
  # Soft delete FREE (7 dias mínimo)
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  
  # Network rules FREE
  network_rules {
    default_action = "Allow"
  }
  
  tags = local.tags
  
  # CRÍTICO: Nunca deletar storage com dados
  lifecycle {
    prevent_destroy = true
  }
}

# ========================================
# 5. USER ASSIGNED IDENTITY
# ========================================

resource "azurerm_user_assigned_identity" "main" {
  name                = local.resource_names.managed_identity
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
  
  # Proteção contra perda de identidade
  lifecycle {
    prevent_destroy = true
  }
}

# ========================================
# 6. KEY VAULT (MANUAL - FORA DO TERRAFORM)
# ========================================
# DECISÃO: Key Vault e Secrets são recursos críticos demais
# para serem gerenciados pelo CI/CD. Devem ser criados manualmente.
# 
# Recursos existentes no Azure (manuais):
# - Key Vault: redmine-ai-reporter-kv
# - Secret: OPENAI-API-KEY 
# - Secret: AZURE-OPENAI-ENDPOINT
# - Secret: AZURE-OPENAI-MODEL
# - Access Policies configuradas manualmente
#
# Este bloco está comentado para evitar conflitos no CI/CD
# ========================================

/*
resource "azurerm_key_vault" "main" {
  name                = local.resource_names.key_vault
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"  # FREE: 10.000 operações/mês
  
  # Configurações FREE
  soft_delete_retention_days = 7    # Mínimo allowed
  purge_protection_enabled   = false # FALSE para evitar custos
  
  # Network access FREE
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
  
  tags = local.tags
  
  # CRÍTICO: Nunca deletar Key Vault com secrets
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

# Key Vault Access Policy - Managed Identity
resource "azurerm_key_vault_access_policy" "managed_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.main.principal_id
  
  secret_permissions = [
    "Get",
    "List"
  ]
}

# Key Vault Access Policy - GitHub Actions (deploy only)
resource "azurerm_key_vault_access_policy" "github_actions" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  
  secret_permissions = [
    "Get",
    "List",
    "Set"
  ]
}
*/

# ========================================
# 7. AZURE OPENAI (STANDARD - necessário para API)
# ========================================

resource "azurerm_cognitive_account" "openai" {
  name                = local.resource_names.openai_account
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "OpenAI"
  sku_name            = "S0"  # Standard necessário para API access
  
  custom_subdomain_name         = local.resource_names.openai_account
  public_network_access_enabled = true
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.tags
  
  # CRÍTICO: Nunca recriar (perde API keys e deployments)
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      custom_subdomain_name,
      tags
    ]
  }
}

# OpenAI Model Deployment - GPT-4o-mini (mais barato)
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
  
  # Proteção contra recriação do modelo
  lifecycle {
    prevent_destroy = true
  }
  
  depends_on = [azurerm_cognitive_account.openai]
}

# ========================================
# 8. APP SERVICE PLAN (FREE TIER)
# ========================================

resource "azurerm_service_plan" "main" {
  name                = local.resource_names.app_service_plan
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Windows"
  sku_name            = "Y1"  # FREE: Consumption plan
  tags                = local.tags
}

# ========================================
# 9. FUNCTION APP (FREE TIER)
# ========================================

resource "azurerm_windows_function_app" "main" {
  name                = local.resource_names.function_app
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  
  https_only = true
  
  # Usar User Assigned Identity
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
    
    # CORS configurado
    cors {
      allowed_origins     = ["*"]
      support_credentials = false
    }
    
    application_stack {
      node_version = "~20"
    }
  }
  
  # Configurações de ambiente
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
    "KEY_VAULT_URI"                         = "https://redmine-ai-reporter-kv.vault.azure.net/"
    
    # Azure OpenAI Settings (via Key Vault para segurança)
    "AZURE_OPENAI_ENDPOINT"         = azurerm_cognitive_account.openai.endpoint
    "AZURE_OPENAI_MODEL_DEPLOYMENT" = azurerm_cognitive_deployment.gpt_model.name
    "AZURE_OPENAI_API_KEY"          = "@Microsoft.KeyVault(VaultName=redmine-ai-reporter-kv;SecretName=OPENAI-API-KEY)"
  }
  
  tags = merge(local.tags, {
    "azd-service-name" = "api"
  })
  
  # Proteção contra recriação (perderia configurações)
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags,
      app_settings["WEBSITE_RUN_FROM_PACKAGE"]
    ]
  }
  
  depends_on = [
    azurerm_storage_account.main,
    azurerm_application_insights.main,
    azurerm_user_assigned_identity.main
    # azurerm_key_vault_access_policy.managed_identity  # GERENCIADO MANUALMENTE
  ]
}

# ========================================
# 10. STATIC WEB APP (FREE TIER)
# ========================================

resource "azurerm_static_web_app" "main" {
  name                = local.resource_names.static_web_app
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_tier            = "Free"  # FREE: 100GB bandwidth/mês
  sku_size            = "Free"
  
  tags = merge(local.tags, {
    "azd-service-name" = "frontend"
  })
  
  # Proteção contra perda de configuração
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

# ========================================
# 11. KEY VAULT SECRETS (MANUAL - FORA DO TERRAFORM)
# ========================================
# DECISÃO: Secrets são dados críticos, devem ser gerenciados manualmente
# para evitar conflitos e perda acidental de dados sensíveis.
#
# Secrets existentes (configurados manualmente):
# - OPENAI-API-KEY: {chave da Azure OpenAI}
# - AZURE-OPENAI-ENDPOINT: {endpoint da Azure OpenAI}
# - AZURE-OPENAI-MODEL: gpt-4o-mini
# ========================================

/*
# IMPORTANTE: Secret com a API Key do Azure OpenAI
resource "azurerm_key_vault_secret" "openai_api_key" {
  name         = "OPENAI-API-KEY"
  value        = azurerm_cognitive_account.openai.primary_access_key
  key_vault_id = azurerm_key_vault.main.id
  
  # CRÍTICO: Nunca recriar este secret
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      value,  # Só atualize manualmente se necessário
      tags
    ]
  }
  
  depends_on = [
    azurerm_key_vault_access_policy.github_actions,
    azurerm_key_vault_access_policy.managed_identity
  ]
}

# Secret adicional: Endpoint (para referência)
resource "azurerm_key_vault_secret" "openai_endpoint" {
  name         = "AZURE-OPENAI-ENDPOINT"
  value        = azurerm_cognitive_account.openai.endpoint
  key_vault_id = azurerm_key_vault.main.id
  
  lifecycle {
    prevent_destroy = true
  }
  
  depends_on = [
    azurerm_key_vault_access_policy.github_actions,
    azurerm_key_vault_access_policy.managed_identity
  ]
}

# Secret: Model Deployment Name
resource "azurerm_key_vault_secret" "openai_model" {
  name         = "AZURE-OPENAI-MODEL"
  value        = azurerm_cognitive_deployment.gpt_model.name
  key_vault_id = azurerm_key_vault.main.id
  
  lifecycle {
    prevent_destroy = true
  }
  
  depends_on = [
    azurerm_key_vault_access_policy.github_actions,
    azurerm_key_vault_access_policy.managed_identity
  ]
}
*/
