# Script de Teste da API Deployada
# Execute este script após o deploy para testar a integração com Azure OpenAI

# Configurações
$functionAppName = "TBD"  # Será preenchido após o deploy
$baseUrl = "https://$functionAppName.azurewebsites.net"

# Teste 1: Health Check
Write-Host "🔍 Testando Health Check..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "$baseUrl/api/health" -Method GET
    Write-Host "✅ Health Check: OK" -ForegroundColor Green
    Write-Host "Response: $($healthResponse | ConvertTo-Json)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Health Check: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 2: Generate Suggestion (Mock - sem credenciais Azure OpenAI)
Write-Host "`n🔍 Testando Generate Suggestion (Mock)..." -ForegroundColor Yellow
$testData = @{
    texto = "Participei de uma reunião sobre Azure DevOps por 2 horas"
} | ConvertTo-Json

try {
    $suggestionResponse = Invoke-RestMethod -Uri "$baseUrl/api/generate-suggestion" -Method POST -Headers @{"Content-Type"="application/json"} -Body $testData
    Write-Host "✅ Generate Suggestion: OK" -ForegroundColor Green
    Write-Host "Source: $($suggestionResponse.source)" -ForegroundColor Cyan
    Write-Host "Confidence: $($suggestionResponse.confianca)" -ForegroundColor Cyan
    Write-Host "Activity: $($suggestionResponse.sugestao.atividade)" -ForegroundColor Cyan
    Write-Host "Hours: $($suggestionResponse.sugestao.horas)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Generate Suggestion: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 3: Generate Suggestion (Azure OpenAI) - quando credenciais estiverem configuradas
Write-Host "`n🔍 Testando Azure OpenAI Integration..." -ForegroundColor Yellow
$complexTestData = @{
    texto = "Hoje desenvolvi uma API REST em Node.js usando Azure Functions, configurei autenticação OAuth2, e implementei testes unitários. Trabalhei das 9h às 17h com 1 hora de almoço, totalizando 7 horas produtivas."
} | ConvertTo-Json

try {
    $aiResponse = Invoke-RestMethod -Uri "$baseUrl/api/generate-suggestion" -Method POST -Headers @{"Content-Type"="application/json"} -Body $complexTestData
    
    if ($aiResponse.source -eq "azure_openai") {
        Write-Host "🎉 Azure OpenAI: FUNCIONANDO!" -ForegroundColor Green
        Write-Host "AI Used: $($aiResponse.ai_used)" -ForegroundColor Green
        Write-Host "Parsed Activity: $($aiResponse.sugestao.atividade)" -ForegroundColor Cyan
        Write-Host "Estimated Hours: $($aiResponse.sugestao.horas)" -ForegroundColor Cyan
    } elseif ($aiResponse.source -eq "mock") {
        Write-Host "⚠️  Azure OpenAI: Usando Mock (credenciais não configuradas)" -ForegroundColor Yellow
        Write-Host "Isso é esperado se as variáveis de ambiente não estiverem configuradas na Function App" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Azure OpenAI Test: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 Resumo dos Testes:" -ForegroundColor Magenta
Write-Host "- Para que o Azure OpenAI funcione, configure as variáveis de ambiente na Function App:" -ForegroundColor White
Write-Host "  * AZURE_OPENAI_ENDPOINT" -ForegroundColor Gray
Write-Host "  * AZURE_OPENAI_API_KEY" -ForegroundColor Gray
Write-Host "  * AZURE_OPENAI_MODEL_DEPLOYMENT" -ForegroundColor Gray
