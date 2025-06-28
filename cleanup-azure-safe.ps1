# Script Seguro para Limpeza do Resource Group Azure
Write-Host "🧹 LIMPEZA SEGURA DO RESOURCE GROUP AZURE" -ForegroundColor Yellow
Write-Host "⚠️  Este script vai deletar APENAS recursos duplicados" -ForegroundColor Red

$RESOURCE_GROUP = "rg-redmine-ai-reporter"

# MANTER (atual funcionando)
$KEEP_TOKEN = "4gs0edzg"
Write-Host "`n✅ MANTER: redmine-ai-$KEEP_TOKEN-*" -ForegroundColor Green

# DUPLICADOS (deletar com segurança)
$DELETE_TOKENS = @("5wnlpjuq", "c41prp7g", "dqx5izg5", "eixgy8nt", "wmlha8wc")

Write-Host "`n🔍 VALIDAÇÃO PRÉVIA:" -ForegroundColor Cyan
Write-Host "1. Testando API atual antes da limpeza..." -ForegroundColor White

# Teste de saúde
try {
    $health = Invoke-RestMethod -Uri "https://redmine-ai-$KEEP_TOKEN-func.azurewebsites.net/api/health" -Method GET -TimeoutSec 10
    Write-Host "   ✅ API funcionando: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API com problema: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   ⚠️  ABORTAR LIMPEZA - API atual não está funcionando!" -ForegroundColor Red
    exit 1
}

Write-Host "`n🗑️  RECURSOS PARA DELETAR (5 conjuntos):" -ForegroundColor Yellow
foreach ($token in $DELETE_TOKENS) {
    Write-Host "❌ Conjunto $token:" -ForegroundColor Red
    Write-Host "   - redmine-ai-$token-swa (Static Web App)" -ForegroundColor Gray
    Write-Host "   - redmine-ai-$token-func (Function App)" -ForegroundColor Gray
    Write-Host "   - redmine-ai-$token-asp (App Service Plan)" -ForegroundColor Gray
    Write-Host "   - redmine-ai-$token-openai (OpenAI)" -ForegroundColor Gray
    Write-Host "   - redmine-ai-$token-ai (Application Insights)" -ForegroundColor Gray
    Write-Host "   - redmine-ai-$token-kv (Key Vault)" -ForegroundColor Gray
    Write-Host "   - redmine-ai-$token-log (Log Analytics)" -ForegroundColor Gray
    Write-Host "   - redmine-ai-$token-mi (Managed Identity)" -ForegroundColor Gray
    Write-Host "   - redmineai$($token.Replace('-',''))st (Storage Account)" -ForegroundColor Gray
}

Write-Host "`n💰 ECONOMIA ESTIMADA: ~USD 100-200/mês" -ForegroundColor Green

Write-Host "`n⚠️  COMANDOS DE LIMPEZA SEGUROS:" -ForegroundColor Cyan
Write-Host "Execute UM de cada vez e monitore:" -ForegroundColor White

foreach ($token in $DELETE_TOKENS) {
    Write-Host "`n# === Deletar conjunto $token ===" -ForegroundColor Yellow
    
    # Ordem segura: aplicações primeiro, infraestrutura depois
    @(
        "redmine-ai-$token-swa",
        "redmine-ai-$token-func", 
        "redmine-ai-$token-asp",
        "redmine-ai-$token-openai",
        "redmine-ai-$token-ai",
        "redmineai$($token.Replace('-',''))st",
        "redmine-ai-$token-log",
        "redmine-ai-$token-mi",
        "redmine-ai-$token-kv"
    ) | ForEach-Object {
        Write-Host "az resource delete --name $_ --resource-group $RESOURCE_GROUP" -ForegroundColor Gray
    }
}

Write-Host "`n🚀 SCRIPT AUTOMATIZADO (USAR COM CUIDADO):" -ForegroundColor Red
Write-Host @"
# EXECUTAR APENAS SE TIVER CERTEZA
`$tokensParaDeletar = @('$($DELETE_TOKENS -join "', '")'))
foreach (`$token in `$tokensParaDeletar) {
    Write-Host "Deletando conjunto: `$token" -ForegroundColor Yellow
    
    # Deletar recursos em ordem segura
    `$recursos = @(
        "redmine-ai-`$token-swa",
        "redmine-ai-`$token-func",
        "redmine-ai-`$token-asp", 
        "redmine-ai-`$token-openai",
        "redmine-ai-`$token-ai",
        "redmineai`$(`$token.Replace('-',''))st",
        "redmine-ai-`$token-log",
        "redmine-ai-`$token-mi",
        "redmine-ai-`$token-kv"
    )
    
    foreach (`$recurso in `$recursos) {
        try {
            az resource delete --name `$recurso --resource-group $RESOURCE_GROUP --yes
            Write-Host "   ✅ Deletado: `$recurso" -ForegroundColor Green
            Start-Sleep -Seconds 2
        } catch {
            Write-Host "   ⚠️  Erro ao deletar `$recurso : `$_" -ForegroundColor Yellow
        }
    }
}
"@ -ForegroundColor Gray

Write-Host "`n🎯 PRÓXIMOS PASSOS:" -ForegroundColor White
Write-Host "1. Confirmar que API redmine-ai-$KEEP_TOKEN-func está funcionando" -ForegroundColor White
Write-Host "2. Executar limpeza gradual (1 conjunto por vez)" -ForegroundColor White
Write-Host "3. Monitorar custos no Azure Portal após cada limpeza" -ForegroundColor White
Write-Host "4. Manter apenas o conjunto $KEEP_TOKEN" -ForegroundColor White

Write-Host "`n✅ STATUS FINAL DESEJADO:" -ForegroundColor Green
Write-Host "- Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host "- Recursos mantidos: redmine-ai-$KEEP_TOKEN-* (9 recursos)" -ForegroundColor White
Write-Host "- Recursos removidos: 5 conjuntos duplicados (45 recursos)" -ForegroundColor White
Write-Host "- Economia: ~USD 100-200/mês" -ForegroundColor White
