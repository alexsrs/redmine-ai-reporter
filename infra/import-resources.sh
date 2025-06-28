#!/bin/bash

# ========================================
# SCRIPT DE IMPORT AUTOMÁTICO TERRAFORM
# ========================================
# Este script importa recursos existentes no Azure para o estado do Terraform
# Evita erro "resource already exists" durante terraform apply

echo "🔄 Iniciando import automático de recursos Azure..."

# Configurações
RESOURCE_GROUP="rg-redmine-ai-reporter"
LOCATION="East US 2"

# Verificar se o Azure CLI está logado
if ! az account show &> /dev/null; then
    echo "❌ Azure CLI não está autenticado. Execute: az login"
    exit 1
fi

# Verificar se o resource group existe
if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo "ℹ️  Resource group $RESOURCE_GROUP não encontrado. Terraform irá criá-lo."
    exit 0
fi

echo "✅ Resource group $RESOURCE_GROUP encontrado. Iniciando imports..."

# Função para importar recurso com verificação
import_resource() {
    local terraform_address="$1"
    local azure_resource_id="$2"
    local resource_name="$3"
    
    echo "🔍 Verificando $resource_name..."
    
    # Verificar se o recurso já existe no estado do Terraform
    if terraform state show "$terraform_address" &> /dev/null; then
        echo "✅ $resource_name já está no estado do Terraform"
        return 0
    fi
    
    # Verificar se o recurso existe no Azure
    if az resource show --ids "$azure_resource_id" &> /dev/null; then
        echo "📥 Importando $resource_name..."
        if terraform import "$terraform_address" "$azure_resource_id"; then
            echo "✅ $resource_name importado com sucesso"
        else
            echo "⚠️  Falha ao importar $resource_name (pode não existir)"
        fi
    else
        echo "ℹ️  $resource_name não existe no Azure - será criado"
    fi
}

# Obter subscription ID atual
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "📋 Usando subscription: $SUBSCRIPTION_ID"

# 1. Resource Group
echo "📁 Importando Resource Group..."
import_resource "azurerm_resource_group.main" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP" \
    "Resource Group"

# 2. Log Analytics Workspace
echo "📊 Importando Log Analytics..."
import_resource "azurerm_log_analytics_workspace.main" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/redmine-ai-reporter-log" \
    "Log Analytics Workspace"

# 3. Application Insights
echo "📈 Importando Application Insights..."
import_resource "azurerm_application_insights.main" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/components/redmine-ai-reporter-ai" \
    "Application Insights"

# 4. Storage Account
echo "💾 Importando Storage Account..."
import_resource "azurerm_storage_account.main" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/redmineaireporterst" \
    "Storage Account"

# 5. User Assigned Identity
echo "🔐 Importando Managed Identity..."
import_resource "azurerm_user_assigned_identity.main" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ManagedIdentity/userAssignedIdentities/redmine-ai-reporter-mi" \
    "User Assigned Identity"

# 6. Key Vault - FORA DO TERRAFORM (MANUAL)
echo "🔑 Key Vault e Secrets são gerenciados manualmente - IGNORANDO"
echo "ℹ️  Recursos manuais existentes:"
echo "    - Key Vault: redmine-ai-reporter-kv"
echo "    - Secrets: OPENAI-API-KEY, AZURE-OPENAI-ENDPOINT, AZURE-OPENAI-MODEL"
echo "    - Access Policies: Configuradas manualmente"

# 7. Azure OpenAI
echo "🤖 Importando Azure OpenAI..."
import_resource "azurerm_cognitive_account.openai" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.CognitiveServices/accounts/redmine-ai-reporter-openai" \
    "Azure OpenAI Account"

# 8. OpenAI Model Deployment
echo "🚀 Importando OpenAI Model Deployment..."
import_resource "azurerm_cognitive_deployment.gpt_model" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.CognitiveServices/accounts/redmine-ai-reporter-openai/deployments/gpt-4o-mini" \
    "GPT-4o-mini Model Deployment"

# 9. App Service Plan
echo "📋 Importando App Service Plan..."
import_resource "azurerm_service_plan.main" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/serverFarms/redmine-ai-reporter-asp" \
    "App Service Plan"

# 10. Function App
echo "⚡ Importando Function App..."
import_resource "azurerm_windows_function_app.main" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/redmine-ai-reporter-func" \
    "Function App"

# 11. Static Web App
echo "🌐 Importando Static Web App..."
import_resource "azurerm_static_web_app.main" \
    "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/staticSites/redmine-ai-reporter-swa" \
    "Static Web App"

# 12. Key Vault - ESTRATÉGIA MANUAL
echo "� Key Vault, Access Policies e Secrets são gerenciados MANUALMENTE"
echo "ℹ️  Motivo: Recursos críticos com dados sensíveis"
echo "ℹ️  Recursos existentes (fora do Terraform):"
echo "    - Key Vault: redmine-ai-reporter-kv"
echo "    - Secrets: OPENAI-API-KEY, AZURE-OPENAI-ENDPOINT, AZURE-OPENAI-MODEL"
echo "    - Access Policies: Configuradas manualmente conforme necessário"
echo "✅ Terraform agora irá IGNORAR estes recursos críticos"

echo "✅ Import automático concluído!"
echo "📝 Execute 'terraform plan' para verificar o estado atual."