# 🔐 CONFIGURAÇÃO DOS SECRETS DO GITHUB ACTIONS

## ⚠️ IMPORTANTE: Configure os seguintes secrets no GitHub

Acesse: **GitHub Repository → Settings → Secrets and variables → Actions → New repository secret**

### **SECRETS NECESSÁRIOS (4 no total):**

#### 1. **AZURE_CLIENT_ID**
- Valor: [Use o Client ID do service principal criado]
- Fonte: Output do comando `az ad sp create-for-rbac`

#### 2. **AZURE_CLIENT_SECRET** 
- Valor: [Use o Client Secret do service principal criado]
- Fonte: Output do comando `az ad sp create-for-rbac`

#### 3. **AZURE_TENANT_ID**
- Valor: [Use o Tenant ID da sua Azure AD]
- Fonte: `az account show --query tenantId -o tsv`

#### 4. **AZURE_SUBSCRIPTION_ID**
- Valor: [Use o Subscription ID onde os recursos serão criados]
- Fonte: `az account show --query id -o tsv`

## 🔧 PASSOS NO GITHUB:

1. **Acesse o repositório no GitHub**
2. **Vá em Settings → Secrets and variables → Actions**
3. **Clique em "New repository secret"**
4. **Adicione cada secret acima (um por vez)**

## ✅ VERIFICAÇÃO:

Após adicionar todos os secrets, você deve ter **4 secrets**:
- ✅ `AZURE_CLIENT_ID`
- ✅ `AZURE_CLIENT_SECRET` 
- ✅ `AZURE_TENANT_ID`
- ✅ `AZURE_SUBSCRIPTION_ID`

> **📝 NOTA:** Não é mais necessário `AZURE_STATIC_WEB_APPS_API_TOKEN` - o token é obtido automaticamente via Azure CLI!

## 🚀 APÓS CONFIGURAR:

1. **Commit as alterações** do workflow
2. **Push para master** (vai triggerar o deploy)
3. **Monitore no GitHub Actions**

## 🔒 SEGURANÇA:

- ✅ Service Principal criado com **mínimas permissões** necessárias
- ✅ Escopo limitado à **subscription específica**
- ✅ Role **Contributor** (necessário para gerenciar recursos)
- ✅ **Secrets protegidos** no GitHub (não visíveis nos logs)

## 🆕 MELHORIAS NA AUTENTICAÇÃO:

**Static Web App Token:**
- ❌ **ANTES:** Usava secret manual `AZURE_STATIC_WEB_APPS_API_TOKEN`
- ✅ **AGORA:** Token obtido dinamicamente via `az staticwebapp secrets list`
- 🎯 **VANTAGEM:** Sempre atualizado, mais seguro, sem manutenção manual

## 📝 COMO CRIAR O SERVICE PRINCIPAL:

```bash
# Criar service principal para GitHub Actions
az ad sp create-for-rbac \
  --name "github-actions-redmine-ai-reporter" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --sdk-auth false
```

**⚠️ IMPORTANTE:** Use os valores retornados deste comando para configurar os secrets no GitHub!
