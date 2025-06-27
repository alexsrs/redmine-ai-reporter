# Script para corrigir o erro do Terraform - Importar Resource Group existente
# Execute este script no diretório infra/

Write-Host "🔧 Corrigindo estado do Terraform..." -ForegroundColor Green

# Navegar para o diretório da infraestrutura
cd infra

# Importar o resource group existente para o estado do Terraform
Write-Host "📥 Importando resource group existente..." -ForegroundColor Yellow
terraform import azurerm_resource_group.main "/subscriptions/$env:AZURE_SUBSCRIPTION_ID/resourceGroups/rg-redmine-ai-reporter-homolog"

# Verificar o estado após importação
Write-Host "✅ Verificando estado após importação..." -ForegroundColor Cyan
terraform plan

Write-Host "🏁 Correção concluída! Agora você pode executar terraform apply novamente." -ForegroundColor Green
