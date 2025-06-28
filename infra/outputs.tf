# ========================================
# OUTPUTS - FREE TIER DEPLOYMENT
# ========================================

# URLs principais da aplicação
output "function_app_url" {
  description = "URL da Azure Function App"
  value       = "https://${azurerm_windows_function_app.main.name}.azurewebsites.net"
}

output "static_web_app_url" {
  description = "URL do Static Web App"
  value       = "https://${azurerm_static_web_app.main.default_host_name}"
}

# Informações para CI/CD
output "function_app_name" {
  description = "Nome da Function App para CI/CD"
  value       = azurerm_windows_function_app.main.name
}

output "static_web_app_name" {
  description = "Nome do Static Web App para CI/CD"
  value       = azurerm_static_web_app.main.name
}

output "resource_group_name" {
  description = "Nome do Resource Group"
  value       = azurerm_resource_group.main.name
}

# Informações do Azure OpenAI
output "openai_endpoint" {
  description = "Endpoint do Azure OpenAI"
  value       = azurerm_cognitive_account.openai.endpoint
  sensitive   = true
}

output "openai_model_deployment" {
  description = "Nome do deployment do modelo"
  value       = azurerm_cognitive_deployment.gpt_model.name
}

# Key Vault para secrets
output "key_vault_uri" {
  description = "URI do Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "managed_identity_client_id" {
  description = "Client ID da Managed Identity"
  value       = azurerm_user_assigned_identity.main.client_id
}

# Identificador do projeto
output "project_name" {
  description = "Nome do projeto (redmine-ai-reporter)"
  value       = "redmine-ai-reporter"
}
