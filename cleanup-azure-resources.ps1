# Script para limpeza de recursos duplicados no Azure
Write-Host "🧹 Limpeza de Recursos Duplicados Azure" -ForegroundColor Red
Write-Host "⚠️  ATENÇÃO: Este script vai deletar recursos antigos!" -ForegroundColor Yellow

# Recursos que vamos MANTER (atual e funcionando)
$KEEP_TOKEN = "4gs0edzg"
Write-Host "✅ Mantendo recursos com token: $KEEP_TOKEN" -ForegroundColor Green

# Tokens antigos para deletar
$DELETE_TOKENS = @(
    "5wnlpjuq",
    "c41prp7g", 
    "dqx5izg5",
    "eixgy8nt",
    "wmlha8wc"
)

Write-Host "`n🗑️  Recursos para deletar:" -ForegroundColor Yellow
foreach ($token in $DELETE_TOKENS) {
    Write-Host "❌ redmine-ai-$token-*" -ForegroundColor Red
}

Write-Host "`n⚠️  ANTES DE CONTINUAR:" -ForegroundColor Yellow
Write-Host "1. Confirme que redmine-ai-4gs0edzg-func está funcionando" -ForegroundColor White
Write-Host "2. Teste a URL: https://redmine-ai-4gs0edzg-func.azurewebsites.net/api/health" -ForegroundColor White
Write-Host "3. Confirme que quer deletar os outros recursos" -ForegroundColor White

Write-Host "`n💰 Economia estimada: ~$50-100/mês" -ForegroundColor Green
Write-Host "🎯 Manter apenas 1 conjunto ao invés de 6" -ForegroundColor Green

Write-Host "`n🔄 Para executar a limpeza via Azure CLI:" -ForegroundColor Cyan
Write-Host "az resource delete --ids \`" -ForegroundColor White

foreach ($token in $DELETE_TOKENS) {
    Write-Host "  /subscriptions/YOUR_SUBSCRIPTION/resourceGroups/rg-redmine-ai-reporter-dev/providers/Microsoft.Web/staticSites/redmine-ai-$token-swa \`" -ForegroundColor Gray
    Write-Host "  /subscriptions/YOUR_SUBSCRIPTION/resourceGroups/rg-redmine-ai-reporter-dev/providers/Microsoft.CognitiveServices/accounts/redmine-ai-$token-openai \`" -ForegroundColor Gray
    Write-Host "  /subscriptions/YOUR_SUBSCRIPTION/resourceGroups/rg-redmine-ai-reporter-dev/providers/Microsoft.KeyVault/vaults/redmine-ai-$token-kv \`" -ForegroundColor Gray
}

Write-Host "`n🎯 Status Atual:" -ForegroundColor White
Write-Host "✅ Funcionando: redmine-ai-4gs0edzg-func" -ForegroundColor Green
Write-Host "❌ Duplicados: 5 conjuntos desnecessários" -ForegroundColor Red
