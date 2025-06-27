# Script para testar a API deployada no Azure
# Execute este script após o deploy estar completo

Write-Host "🧪 Testando API Deployada no Azure..." -ForegroundColor Green

# Aguardar um pouco para o deploy estar disponível
Write-Host "⏱️ Aguardando 30 segundos para stabilização..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Teste 1: Health Check
Write-Host "`n🔍 Teste 1: Health Check" -ForegroundColor Cyan
try {
    $healthResponse = Invoke-RestMethod -Uri "https://redmine-ai-wmlha8wc-function-app.azurewebsites.net/api/health" -Method GET
    Write-Host "✅ Health Check: $($healthResponse)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health Check falhou: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 2: Generate Suggestion (deve usar Azure OpenAI real)
Write-Host "`n🔍 Teste 2: Generate Suggestion com Azure OpenAI" -ForegroundColor Cyan
$testBody = @{
    texto = "Hoje trabalhei 4 horas desenvolvendo uma API em Node.js com Azure Functions integrada ao Azure OpenAI para o projeto Redmine"
} | ConvertTo-Json

try {
    $suggestionResponse = Invoke-RestMethod -Uri "https://redmine-ai-wmlha8wc-function-app.azurewebsites.net/api/generate-suggestion" -Method POST -Headers @{"Content-Type"="application/json"} -Body $testBody
    
    Write-Host "✅ Suggestion Response:" -ForegroundColor Green
    Write-Host "   Source: $($suggestionResponse.source)" -ForegroundColor $(if ($suggestionResponse.source -eq "azure_openai") { "Green" } else { "Yellow" })
    Write-Host "   AI Used: $($suggestionResponse.ai_used)" -ForegroundColor $(if ($suggestionResponse.ai_used) { "Green" } else { "Yellow" })
    Write-Host "   Tarefa: $($suggestionResponse.sugestao.tarefa)" -ForegroundColor White
    Write-Host "   Horas: $($suggestionResponse.sugestao.horas)" -ForegroundColor White
    Write-Host "   Confiança: $($suggestionResponse.confianca)" -ForegroundColor White
    
    if ($suggestionResponse.source -eq "azure_openai") {
        Write-Host "🎉 SUCESSO: Azure OpenAI está funcionando!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ ATENÇÃO: Usando fallback mock" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Generate Suggestion falhou: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🏁 Teste concluído!" -ForegroundColor Green
