# Teste Simples da API
$API_URL = "https://redmine-ai-reporter-func.azurewebsites.net"

Write-Host "Testando Health Check..." -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "$API_URL/api/health" -Method GET
    Write-Host "HEALTH: OK - $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "HEALTH: ERRO - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTestando Generate Suggestion..." -ForegroundColor Cyan
$body = @{ texto = "Desenvolvimento de sistema web" } | ConvertTo-Json
try {
    $response = Invoke-RestMethod -Uri "$API_URL/api/generate-suggestion" -Method POST -Body $body -ContentType "application/json"
    Write-Host "SUGGESTION: OK" -ForegroundColor Green
} catch {
    Write-Host "SUGGESTION: ERRO 500" -ForegroundColor Red
}
