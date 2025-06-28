# Teste da API deployada com nomes amigaveis
$API_URL = "https://redmine-ai-reporter-func.azurewebsites.net"

Write-Host "🧪 TESTANDO API COM NOMES AMIGAVEIS" -ForegroundColor Yellow
Write-Host "URL: $API_URL" -ForegroundColor Cyan

Write-Host "`n1. Health Check..." -ForegroundColor White
try {
    $health = Invoke-RestMethod -Uri "$API_URL/api/health" -Method GET -TimeoutSec 15
    Write-Host "✅ HEALTH: $($health.status)" -ForegroundColor Green
    Write-Host "   Timestamp: $($health.timestamp)" -ForegroundColor Gray
} catch {
    Write-Host "❌ HEALTH: ERRO - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Generate Suggestion..." -ForegroundColor White
$body = @{
    texto = "Desenvolvimento de feature de relatórios em React"
    description = "Implementacao de dashboard com graficos"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_URL/api/generate-suggestion" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 20
    Write-Host "✅ SUGGESTION: OK" -ForegroundColor Green
    Write-Host "   Sugestao: $($response.sugestao.tarefa)" -ForegroundColor Gray
    Write-Host "   Horas: $($response.sugestao.horas)" -ForegroundColor Gray
    Write-Host "   Source: $($response.source)" -ForegroundColor Gray
} catch {
    Write-Host "❌ SUGGESTION: ERRO - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "   Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
    }
}

Write-Host "`n🏁 Teste concluido!" -ForegroundColor Yellow
