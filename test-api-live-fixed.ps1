# Teste rápido da API Azure Functions
Write-Host "🧪 Testando API Azure Functions..." -ForegroundColor Yellow

# URL da API deployada
$API_URL = "https://redmine-ai-4gs0edzg-func.azurewebsites.net"

try {
    # Teste 1: Health Check
    Write-Host "📋 Teste 1: Health Check" -ForegroundColor Cyan
    $healthResponse = Invoke-RestMethod -Uri "$API_URL/api/health" -Method GET
    Write-Host "✅ Health Check: $($healthResponse | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health Check falhou: $_" -ForegroundColor Red
}

try {
    # Teste 2: Generate Suggestion (deve usar Azure OpenAI real)
    Write-Host "`n🤖 Teste 2: Generate Suggestion com Azure OpenAI" -ForegroundColor Cyan
    $body = @{
        texto = "Implementei correção de bug no sistema de relatórios. comecei as 9h e terminei às 17h com 1 hora de almoço "
    } | ConvertTo-Json

    $suggestionResponse = Invoke-RestMethod -Uri "$API_URL/api/generate-suggestion" -Method POST -Body $body -ContentType "application/json"
    Write-Host "✅ Generate Suggestion: $($suggestionResponse.sugestao.substring(0, 100))..." -ForegroundColor Green
} catch {
    Write-Host "❌ Generate Suggestion falhou: $_" -ForegroundColor Red
}

Write-Host "`n🎉 Teste concluído!" -ForegroundColor Yellow
