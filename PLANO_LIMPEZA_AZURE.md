# PLANO DE ACAO: Limpeza Azure + Protecao Terraform

## 🎯 OBJETIVO

- Manter apenas 1 conjunto de recursos funcionando (4gs0edzg)
- Deletar 5 conjuntos duplicados (economia ~USD 100-200/mes)
- Proteger recursos criticos no Terraform

## ✅ JA FEITO

- [x] Adicionadas protecoes lifecycle no Terraform (Azure OpenAI + Key Vault)
- [x] Script de limpeza gerado com comandos especificos
- [x] Identificados recursos duplicados no resource group

## 🚀 PROXIMOS PASSOS

### 1. PROTEGER TERRAFORM (FEITO)

```hcl
# Azure OpenAI protegido contra recriacao
lifecycle {
  prevent_destroy = true
  ignore_changes = [custom_subdomain_name, tags]
}

# Key Vault protegido contra perda de secrets
lifecycle {
  prevent_destroy = true
  ignore_changes = [tags]
}
```

### 2. EXECUTAR LIMPEZA AZURE

Execute UM conjunto por vez:

#### Conjunto 1: 5wnlpjuq

```bash
az resource delete --name redmine-ai-5wnlpjuq-swa --resource-group rg-redmine-ai-reporter
az resource delete --name redmine-ai-5wnlpjuq-func --resource-group rg-redmine-ai-reporter
az resource delete --name redmine-ai-5wnlpjuq-asp --resource-group rg-redmine-ai-reporter
az resource delete --name redmine-ai-5wnlpjuq-openai --resource-group rg-redmine-ai-reporter
az resource delete --name redmine-ai-5wnlpjuq-ai --resource-group rg-redmine-ai-reporter
az resource delete --name redmine-ai-5wnlpjuq-kv --resource-group rg-redmine-ai-reporter
az resource delete --name redmine-ai-5wnlpjuq-log --resource-group rg-redmine-ai-reporter
az resource delete --name redmine-ai-5wnlpjuq-mi --resource-group rg-redmine-ai-reporter
az resource delete --name redmineai5wnlpjuqst --resource-group rg-redmine-ai-reporter
```

#### Repetir para: c41prp7g, dqx5izg5, eixgy8nt, wmlha8wc

### 3. VALIDAR APOS CADA LIMPEZA

```powershell
# Testar API atual
Invoke-RestMethod -Uri "https://redmine-ai-4gs0edzg-func.azurewebsites.net/api/health"
```

### 4. CORRIGIR ERRO 500 NO GENERATE-SUGGESTION

Possiveis causas:

- [ ] Variaveis ambiente Azure OpenAI ausentes
- [ ] Problema de permissao Key Vault -> Function App
- [ ] API Key invalida/expirada
- [ ] Deployment modelo Azure OpenAI

## 📊 RESULTADO ESPERADO

### ANTES (atual)

- 6 conjuntos completos = 54 recursos
- Custo: ~USD 300-600/mes
- Complexidade: Alta

### DEPOIS (objetivo)

- 1 conjunto funcional = 9 recursos
- Custo: ~USD 50-100/mes
- Complexidade: Baixa
- Economia: ~USD 200-500/mes

## ⚠️ CUIDADOS

1. **Nunca deletar** redmine-ai-4gs0edzg-\* (atual funcionando)
2. **Testar** API apos cada limpeza
3. **Monitorar** custos no Azure Portal
4. **Backup** configuracoes importantes antes da limpeza
5. **Executar** limpeza gradualmente (1 conjunto por vez)

## 🔧 TERRAFORM PROTEGIDO

- Azure OpenAI: `prevent_destroy = true`
- Key Vault: `prevent_destroy = true`
- API Keys: Nao serao recriadas acidentalmente
