# Script para Limpeza dos 6 Conjuntos de Recursos Duplicados
Write-Host "🧹 LIMPEZA DE RECURSOS DUPLICADOS AZURE" -ForegroundColor Red
Write-Host "⚠️  Identificados 6 conjuntos completos de recursos!" -ForegroundColor Yellow

$RESOURCE_GROUP = "rg-redmine-ai-reporter"

# ATUAL (MANTER)
$CURRENT_TOKEN = "4gs0edzg"
Write-Host "`n✅ MANTER (atual funcionando): redmine-ai-$CURRENT_TOKEN-*" -ForegroundColor Green

# DUPLICADOS (DELETAR)
$DUPLICATE_TOKENS = @("5wnlpjuq", "c41prp7g", "dqx5izg5", "eixgy8nt", "wmlha8wc")

Write-Host "`n❌ DELETAR (5 conjuntos duplicados):" -ForegroundColor Red
foreach ($token in $DUPLICATE_TOKENS) {
    Write-Host "   • redmine-ai-$token-ai (Cognitive Services)" -ForegroundColor Gray
    Write-Host "   • redmine-ai-$token-asp (App Service Plan)" -ForegroundColor Gray
    Write-Host "   • redmine-ai-$token-func (Function App)" -ForegroundColor Gray
    Write-Host "   • redmine-ai-$token-kv (Key Vault)" -ForegroundColor Gray
    Write-Host "   • redmine-ai-$token-log (Log Analytics)" -ForegroundColor Gray
    Write-Host "   • redmine-ai-$token-mi (Managed Identity)" -ForegroundColor Gray
    Write-Host "   • redmine-ai-$token-openai (OpenAI)" -ForegroundColor Gray
    Write-Host "   • redmine-ai-$token-swa (Static Web App)" -ForegroundColor Gray
    Write-Host "   • redmineai$($token.Replace('-',''))st (Storage Account)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "💰 ECONOMIA ESTIMADA: ~$80-150/mês" -ForegroundColor Green
Write-Host "🎯 Reduzir de 6 para 1 conjunto de recursos" -ForegroundColor Green

Write-Host "`n🔍 VALIDAÇÃO ANTES DA LIMPEZA:" -ForegroundColor Cyan
Write-Host "1. Testar URL atual: https://redmine-ai-$CURRENT_TOKEN-func.azurewebsites.net/api/health" -ForegroundColor White
Write-Host "2. Confirmar que o frontend está funcionando" -ForegroundColor White
Write-Host "3. Verificar se não há deployments em andamento" -ForegroundColor White

Write-Host "`n🛠️  COMANDOS PARA LIMPEZA MANUAL:" -ForegroundColor Yellow

foreach ($token in $DUPLICATE_TOKENS) {
    Write-Host "`n# Deletar conjunto: $token" -ForegroundColor Cyan
    
    $resources = @(
        "redmine-ai-$token-swa",
        "redmine-ai-$token-func", 
        "redmine-ai-$token-asp",
        "redmine-ai-$token-openai",
        "redmine-ai-$token-ai",
        "redmine-ai-$token-kv",
        "redmine-ai-$token-log",
        "redmine-ai-$token-mi",
        "redmineai$($token.Replace('-',''))st"
    )
    
    foreach ($resource in $resources) {
        Write-Host "az resource delete --name $resource --resource-group $RESOURCE_GROUP --resource-type Microsoft.Web/staticSites" -ForegroundColor Gray
    }
}

Write-Host "`n📋 SCRIPT AUTOMÁTICO (usar com cuidado):" -ForegroundColor Yellow
Write-Host @"
# ⚠️ EXECUTAR APENAS APÓS VALIDAÇÃO
foreach (`$token in @('$($DUPLICATE_TOKENS -join "', '")')) {
    Write-Host "Deletando conjunto: `$token" -ForegroundColor Red
    az group delete --name "rg-temp-`$token" --yes --no-wait 2>null
    # Deletar recursos individuais...
}
"@ -ForegroundColor Gray

Write-Host "`n🎯 PRÓXIMOS PASSOS:" -ForegroundColor White
Write-Host "1. Validar que redmine-ai-$CURRENT_TOKEN-* está 100% funcional" -ForegroundColor White
Write-Host "2. Fazer backup das configurações importantes" -ForegroundColor White  
Write-Host "3. Executar limpeza gradualmente (1 conjunto por vez)" -ForegroundColor White
Write-Host "4. Monitorar custos no Azure Portal" -ForegroundColor White

Write-Host "`n⚠️  LEMBRE-SE: Sempre teste antes de deletar recursos em producao!" -ForegroundColor Red
