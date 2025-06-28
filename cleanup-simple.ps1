# Script Simples para Limpeza Azure
Write-Host "LIMPEZA AZURE RESOURCE GROUP" -ForegroundColor Yellow

$RG = "rg-redmine-ai-reporter"
$MANTER = "4gs0edzg"
$DELETAR = @("5wnlpjuq", "c41prp7g", "dqx5izg5", "eixgy8nt", "wmlha8wc")

Write-Host ""
Write-Host "MANTER: redmine-ai-$MANTER-*" -ForegroundColor Green

Write-Host ""
Write-Host "DELETAR (5 conjuntos):" -ForegroundColor Red
foreach ($token in $DELETAR) {
    Write-Host "  -> redmine-ai-$token-*" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "COMANDOS PARA EXECUTAR:" -ForegroundColor Cyan

foreach ($token in $DELETAR) {
    Write-Host ""
    Write-Host "# Deletar conjunto $token" -ForegroundColor Yellow
    Write-Host "az resource delete --name redmine-ai-$token-swa --resource-group $RG" -ForegroundColor Gray
    Write-Host "az resource delete --name redmine-ai-$token-func --resource-group $RG" -ForegroundColor Gray
    Write-Host "az resource delete --name redmine-ai-$token-asp --resource-group $RG" -ForegroundColor Gray
    Write-Host "az resource delete --name redmine-ai-$token-openai --resource-group $RG" -ForegroundColor Gray
    Write-Host "az resource delete --name redmine-ai-$token-ai --resource-group $RG" -ForegroundColor Gray
    Write-Host "az resource delete --name redmine-ai-$token-kv --resource-group $RG" -ForegroundColor Gray
    Write-Host "az resource delete --name redmine-ai-$token-log --resource-group $RG" -ForegroundColor Gray
    Write-Host "az resource delete --name redmine-ai-$token-mi --resource-group $RG" -ForegroundColor Gray
    $storage = "redmineai$($token.Replace('-',''))st"
    Write-Host "az resource delete --name $storage --resource-group $RG" -ForegroundColor Gray
}

Write-Host ""
Write-Host "ECONOMIA: ~100-200 USD/mes" -ForegroundColor Green
Write-Host "RESULTADO: 1 conjunto ao inves de 6" -ForegroundColor White
