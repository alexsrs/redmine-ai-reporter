# Analise de Recursos Duplicados Azure
Write-Host "SITUACAO ATUAL: 6 conjuntos completos de recursos duplicados!" -ForegroundColor Red

$ATUAL = "4gs0edzg"
$DUPLICADOS = @("5wnlpjuq", "c41prp7g", "dqx5izg5", "eixgy8nt", "wmlha8wc")

Write-Host ""
Write-Host "MANTER (funcionando): redmine-ai-$ATUAL-*" -ForegroundColor Green
Write-Host ""

Write-Host "DELETAR (5 conjuntos):" -ForegroundColor Red
foreach ($token in $DUPLICADOS) {
    Write-Host "  -> redmine-ai-$token-*" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "ECONOMIA: ~80-150 dolares/mes" -ForegroundColor Green
Write-Host "ACAO: Deletar 5 dos 6 conjuntos duplicados" -ForegroundColor White

Write-Host ""
Write-Host "PASSOS SEGUROS:" -ForegroundColor Cyan
Write-Host "1. Validar que redmine-ai-$ATUAL-func esta 100% funcional" -ForegroundColor White
Write-Host "2. Fazer backup das configuracoes importantes" -ForegroundColor White
Write-Host "3. Deletar 1 conjunto por vez" -ForegroundColor White
Write-Host "4. Monitorar custos no Azure Portal" -ForegroundColor White

Write-Host ""
Write-Host "URL PARA TESTAR:" -ForegroundColor Cyan
Write-Host "https://redmine-ai-$ATUAL-func.azurewebsites.net/api/health" -ForegroundColor White
