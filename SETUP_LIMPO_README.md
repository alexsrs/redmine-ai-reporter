# 🚀 SETUP LIMPO - FREE TIER PROTEGIDO

## ✅ O QUE FOI FEITO

### 1. **LIMPEZA COMPLETA**

- [x] Removidos todos os recursos duplicados do Azure Portal
- [x] Limpos arquivos Terraform antigos (state, plans, .terraform)
- [x] Recriados arquivos de infraestrutura do zero

### 2. **CONFIGURAÇÃO FREE TIER**

- [x] **Storage Account**: Standard LRS (FREE)
- [x] **Function App**: Consumption Plan Y1 (FREE)
- [x] **Static Web App**: Free tier (100GB/mês)
- [x] **Log Analytics**: PerGB2018 + 0.5GB quota (FREE)
- [x] **Application Insights**: Web + sampling 100% (FREE)
- [x] **Key Vault**: Standard + 10k operações (FREE)
- [x] **Azure OpenAI**: S0 Standard (pay-per-use mínimo)

### 3. **PROTEÇÕES ANTI-RECRIAÇÃO**

```hcl
# Todos os recursos críticos protegidos:
lifecycle {
  prevent_destroy = true  # Nunca deletar
  ignore_changes = [...]  # Ignorar mudanças não-críticas
}
```

**Recursos protegidos:**

- ✅ Azure OpenAI (API keys preservadas)
- ✅ Key Vault (secrets preservados)
- ✅ Function App (configurações preservadas)
- ✅ Storage Account (dados preservados)
- ✅ Managed Identity (permissões preservadas)
- ✅ Resource Token (nomes únicos preservados)

### 4. **NOVO WORKFLOW CI/CD**

- ✅ Deploy seguro sem recriação
- ✅ Teste automático de API health
- ✅ Validação completa pós-deploy
- ✅ Relatório de custos FREE tier

## 🎯 COMO USAR

### **Deploy Inicial**

```bash
# 1. Fazer push para master
git add .
git commit -m "Setup limpo FREE tier"
git push origin master

# 2. Aguardar workflow completar (~10-15 min)
# 3. Testar URLs fornecidas no log
```

### **Deploys Subsequentes**

- ✅ **NUNCA** recriam recursos existentes
- ✅ **SEMPRE** preservam API keys
- ✅ **APENAS** atualizam código da aplicação
- ✅ **ZERO** downtime para recursos críticos

## 📊 CUSTOS ESPERADOS

### **FREE TIER GARANTIDO**

- Storage: **$0** (5GB inclusos)
- Function App: **$0** (1M execuções)
- Static Web App: **$0** (100GB bandwidth)
- Log Analytics: **$0** (5GB inclusos)
- Application Insights: **$0** (1GB inclusos)
- Key Vault: **$0** (10k operações)

### **APENAS PAGO**

- Azure OpenAI: **~$1-5/mês** (uso real)
- **TOTAL: ~$1-5/mês máximo**

## 🔧 ARQUIVOS PRINCIPAIS

### **Infraestrutura**

- `infra/main.tf` - Recursos FREE tier protegidos
- `infra/variables.tf` - Variáveis FREE tier
- `infra/terraform.tfvars` - Configuração limpa
- `infra/outputs.tf` - Outputs necessários

### **CI/CD**

- `.github/workflows/deploy-clean.yml` - Pipeline protegido

### **Aplicação**

- `src/api/` - Azure Functions (Node.js)
- `src/frontend/` - React + Vite + Tailwind

## ⚠️ IMPORTANTES

### **NUNCA FAZER**

- ❌ Deletar resource group pelo Portal
- ❌ Alterar resource_token após criação
- ❌ Remover lifecycle protections
- ❌ Fazer terraform destroy

### **SEMPRE FAZER**

- ✅ Usar Git para mudanças
- ✅ Testar localmente antes do push
- ✅ Monitorar custos no Azure Portal
- ✅ Manter backups das configurações

## 🧪 TESTES

### **Automáticos (CI/CD)**

- Health check da API
- Conectividade frontend
- Validação de recursos

### **Manuais**

```bash
# Testar API diretamente
curl https://[FUNCTION-NAME].azurewebsites.net/api/health

# Testar geração de sugestões
curl -X POST https://[FUNCTION-NAME].azurewebsites.net/api/generate-suggestion \
  -H "Content-Type: application/json" \
  -d '{"texto":"Desenvolvimento de API"}'
```

## 🚨 TROUBLESHOOTING

### **Se algo der errado:**

1. Verificar logs no GitHub Actions
2. Verificar Application Insights no Azure Portal
3. Testar API health endpoint
4. Verificar variáveis de ambiente na Function App

### **Rollback seguro:**

```bash
# O Terraform sempre preserva recursos críticos
cd infra
terraform plan  # Ver o que mudaria
# Se necessário, apenas reverter código
```

## 🎉 RESULTADO ESPERADO

- **Custo: ~$1-5/mês** (praticamente FREE)
- **Deploy: ~10-15 min** (primeira vez)
- **Redeploy: ~5-8 min** (atualizações)
- **Uptime: 99.9%** (Azure SLA)
- **Zero perda de dados** em redeploys
