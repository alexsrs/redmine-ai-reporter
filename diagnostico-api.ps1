# Script para Diagnosticar Problema no Generate-Suggestion
Write-Host "DIAGNOSTICO: Erro 500 no Generate-Suggestion" -ForegroundColor Red

$FUNCTION_URL = "https://redmine-ai-4gs0edzg-func.azurewebsites.net"

Write-Host ""
Write-Host "1. TESTANDO HEALTH CHECK:" -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "$FUNCTION_URL/api/health" -Method GET -TimeoutSec 10
    Write-Host "   OK - Status: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "   ERRO - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. TESTANDO GENERATE-SUGGESTION:" -ForegroundColor Cyan
$body = @{
    texto = "Configuracao de servidor web Apache"
    description = "Configuracao de servidor web Apache"
    issueType = "Task"
    project = "TechProject"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$FUNCTION_URL/api/generate-suggestion" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 15
    Write-Host "   OK - Response: $response" -ForegroundColor Green
} catch {
    Write-Host "   ERRO 500 - Problema interno" -ForegroundColor Red
    Write-Host "   Details: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "3. POSSIVEIS CAUSAS DO ERRO 500:" -ForegroundColor Yellow
Write-Host "   a) Variaveis de ambiente Azure OpenAI ausentes/incorretas" -ForegroundColor White
Write-Host "   b) Problema na integracao com Azure OpenAI" -ForegroundColor White  
Write-Host "   c) Erro no parsing do JSON de resposta" -ForegroundColor White
Write-Host "   d) Timeout na chamada do Azure OpenAI" -ForegroundColor White

Write-Host ""
Write-Host "4. SOLUCOES RECOMENDADAS:" -ForegroundColor Green
Write-Host "   1. Verificar variáveis no Azure Portal -> Function App -> Configuration" -ForegroundColor White
Write-Host "   2. Testar conexao direta com Azure OpenAI" -ForegroundColor White
Write-Host "   3. Verificar logs da Function App no Azure Portal" -ForegroundColor White
Write-Host "   4. Validar se o fallback mock está funcionando" -ForegroundColor White

Write-Host ""
Write-Host "5. VARIAVEIS NECESSARIAS:" -ForegroundColor Cyan
Write-Host "   - AZURE_OPENAI_ENDPOINT" -ForegroundColor White
Write-Host "   - AZURE_OPENAI_API_KEY" -ForegroundColor White  
Write-Host "   - AZURE_OPENAI_MODEL_DEPLOYMENT (default: gpt-4o-mini)" -ForegroundColor White

Write-Host ""
Write-Host "6. FUNCIONALIDADE ATUAL:" -ForegroundColor White
Write-Host "   Health: FUNCIONANDO" -ForegroundColor Green
Write-Host "   Generate-Suggestion: ERRO 500" -ForegroundColor Red
Write-Host "   Frontend: Funcionando (mas sem sugestoes)" -ForegroundColor Yellow
