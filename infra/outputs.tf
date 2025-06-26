# Outputs for Terraform configuration

# Resource Group outputs
output "RESOURCE_GROUP_ID" {
  description = "ID do Resource Group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "Nome do Resource Group"
  value       = azurerm_resource_group.main.name
}

output "environment_name" {
  description = "Nome do ambiente"
  value       = var.environment_name
}

output "app_name" {
  description = "Nome da aplicação"
  value       = var.app_name
}

# Static Web App outputs
output "AZURE_STATIC_WEB_APP_NAME" {
  description = "Nome da Static Web App"
  value       = azurerm_static_web_app.main.name
}

output "AZURE_STATIC_WEB_APP_URL" {
  description = "URL da Static Web App"
  value       = "https://${azurerm_static_web_app.main.default_host_name}"
}

# Function App outputs
output "AZURE_FUNCTION_APP_NAME" {
  description = "Nome da Function App"
  value       = azurerm_windows_function_app.main.name
}

output "AZURE_FUNCTION_APP_URL" {
  description = "URL da Function App"
  value       = "https://${azurerm_windows_function_app.main.default_hostname}"
}

# Storage outputs
output "AZURE_STORAGE_ACCOUNT_NAME" {
  description = "Nome da Storage Account"
  value       = azurerm_storage_account.main.name
}

# Key Vault outputs
output "AZURE_KEY_VAULT_NAME" {
  description = "Nome do Key Vault"
  value       = azurerm_key_vault.main.name
}

output "AZURE_KEY_VAULT_URI" {
  description = "URI do Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

# Application Insights outputs
output "AZURE_APPLICATION_INSIGHTS_NAME" {
  description = "Nome do Application Insights"
  value       = azurerm_application_insights.main.name
}

output "AZURE_APPLICATION_INSIGHTS_CONNECTION_STRING" {
  description = "Connection String do Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

# Managed Identity outputs
output "AZURE_MANAGED_IDENTITY_NAME" {
  description = "Nome da Managed Identity"
  value       = azurerm_user_assigned_identity.main.name
}

output "AZURE_MANAGED_IDENTITY_CLIENT_ID" {
  description = "Client ID da Managed Identity"
  value       = azurerm_user_assigned_identity.main.client_id
}

# OpenAI outputs
output "AZURE_OPENAI_NAME" {
  description = "Nome do Azure OpenAI Service"
  value       = azurerm_cognitive_account.openai.name
}

output "AZURE_OPENAI_ENDPOINT" {
  description = "Endpoint do Azure OpenAI Service"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "AZURE_OPENAI_MODEL_DEPLOYMENT" {
  description = "Nome do modelo deployado"
  value       = azurerm_cognitive_deployment.gpt_model.name
}
