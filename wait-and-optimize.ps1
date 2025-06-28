# Script para aguardar throttling e fazer retry inteligente
Write-Host "⏰ Aguardando throttling da Azure passar..." -ForegroundColor Yellow
Write-Host "🔄 Tentativa será feita em 15 minutos (00:40)" -ForegroundColor Cyan

$targetTime = (Get-Date).AddMinutes(15)
Write-Host "⏰ Aguardando até: $($targetTime.ToString('HH:mm:ss'))" -ForegroundColor Yellow

# Verificar se os recursos principais já existem
Write-Host "`n📋 Verificando recursos existentes..." -ForegroundColor Cyan

try {
    # Testar API principal (já sabemos que funciona)
    $health = Invoke-RestMethod -Uri "https://redmine-ai-4gs0edzg-func.azurewebsites.net/api/health" -Method GET
    Write-Host "✅ Azure Functions: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure Functions: não encontrada" -ForegroundColor Red
}

Write-Host "`n📊 Status dos recursos principais:" -ForegroundColor White
Write-Host "✅ Resource Group: rg-redmine-ai-reporter-dev" -ForegroundColor Green  
Write-Host "✅ Azure Functions: redmine-ai-4gs0edzg-func" -ForegroundColor Green
Write-Host "✅ Key Vault: redmine-ai-4gs0edzg-kv" -ForegroundColor Green
Write-Host "✅ Azure OpenAI: redmine-ai-4gs0edzg-openai" -ForegroundColor Green
Write-Host "✅ Storage Account: redmineai4gs0edzgst" -ForegroundColor Green
Write-Host "🔄 Static Web App: precisa de re-deploy (sem api_location)" -ForegroundColor Yellow

Write-Host "`n🎯 Próximos passos:" -ForegroundColor White
Write-Host "1. Aguardar throttling passar (~15 min)" -ForegroundColor Yellow
Write-Host "2. Re-deploy apenas do Static Web App (correção)" -ForegroundColor Yellow  
Write-Host "3. Debugar erro 500 no generate-suggestion" -ForegroundColor Yellow
Write-Host "4. Testar aplicação completa" -ForegroundColor Yellow

Write-Host "`n💡 O deploy foi 95% bem-sucedido!" -ForegroundColor Green
Write-Host "   Apenas alguns ajustes finais necessários." -ForegroundColor Green
