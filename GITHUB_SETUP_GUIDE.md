# 🔐 CONFIGURAÇÃO DOS SECRETS DO GITHUB ACTIONS

## ⚠️ IMPORTANTE: Configure o seguinte secret no GitHub

Acesse: **GitHub Repository → Settings → Secrets and variables → Actions → New repository secret**

### **SECRET NECESSÁRIO (1 apenas):**

#### **AZURE_CREDENTIALS**
- **Nome do Secret:** `AZURE_CREDENTIALS`
- **Valor:** JSON completo do service principal
- **Formato:**
```json
{
  "clientId": "[SEU_CLIENT_ID]",
  "clientSecret": "[SEU_CLIENT_SECRET]", 
  "subscriptionId": "57709152-8595-4415-a679-06b2fcd781aa",
  "tenantId": "b0864049-6d5c-4766-83a4-893358eaf2a5"
}
```

## 🔧 PASSOS NO GITHUB:

1. **Acesse o repositório no GitHub**
2. **Vá em Settings → Secrets and variables → Actions**
3. **Clique em "New repository secret"**
4. **Nome:** `AZURE_CREDENTIALS`
5. **Value:** Cole o JSON acima com suas credenciais

## ✅ VERIFICAÇÃO:

Após configurar, você deve ter **1 secret**:
- ✅ `AZURE_CREDENTIALS`

## 🚀 APÓS CONFIGURAR:

1. **Commit as alterações** do workflow  
2. **Push para master** (vai triggerar o deploy)
3. **Monitore no GitHub Actions**

## 🔒 VANTAGENS DA ABORDAGEM ATUAL:

- ✅ **1 secret** apenas (mais simples)
- ✅ **Formato padrão** do Azure CLI
- ✅ **Compatível** com `azure/login@v2`
- ✅ **Mais seguro** (tudo em um secret)

## 📝 COMO CRIAR O SERVICE PRINCIPAL:

```bash
# Criar service principal para GitHub Actions (retorna o JSON completo)
az ad sp create-for-rbac \
  --name "github-actions-redmine-ai-reporter" \
  --role "Contributor" \
  --scopes "/subscriptions/57709152-8595-4415-a679-06b2fcd781aa" \
  --sdk-auth
```

**💡 DICA:** Use a flag `--sdk-auth` para obter o formato JSON correto!

## 🆕 MELHORIAS:

**Antes (4 secrets):**
- ❌ `AZURE_CLIENT_ID`
- ❌ `AZURE_CLIENT_SECRET` 
- ❌ `AZURE_TENANT_ID`
- ❌ `AZURE_SUBSCRIPTION_ID`

**Agora (1 secret):**
- ✅ `AZURE_CREDENTIALS` (contém tudo)

**Static Web App Token:**
- ✅ Obtido dinamicamente via `az staticwebapp secrets list`
- ✅ Sempre atualizado, mais seguro

**⚠️ IMPORTANTE:** Use as credenciais geradas via Azure CLI com `--sdk-auth`!
