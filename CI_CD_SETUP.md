# Configuração do CI/CD Pipeline

Este projeto possui um pipeline de CI/CD automático configurado para deploy contínuo na branch `main`.

## ⚠️ IMPORTANTE: Workflow Antigo Removido

**Foi removido um workflow conflitante** (`.github/workflows/azure-deploy.yml`) que estava causando deploys automáticos indesejados. Agora apenas o pipeline principal (`deploy-homologacao.yml`) está ativo.

## Configuração dos Secrets no GitHub

Para que o pipeline funcione, configure os seguintes secrets:

### 1. Criar Environment `homologacao`

1. Vá para: https://github.com/alexsrs/redmine-ai-reporter
2. Settings > Environments > New environment
3. Nome: `homologacao`

### 2. Adicionar Secrets ao Environment

No environment `homologacao`, adicione:

```
AZURE_CLIENT_ID: 9cedaab6-8d0d-4d44-bf38-99b6dba13a4b
AZURE_TENANT_ID: b0864049-6d5c-4766-83a4-893358eaf2a5
AZURE_SUBSCRIPTION_ID: e6cf6630-8f1c-406d-a232-31c0edf55c2a
AZURE_STATIC_WEB_APPS_API_TOKEN: b0f694e6d4123c1b0167545ff54a46ca0ba34c7150d61aeb1d5935a3fdcb625701-4e6afefa-cbf2-4885-bfe3-11f9b11285d300f051809136280f
```

## Service Principal

- **Nome**: redmine-ai-reporter-cicd
- **App ID**: 9cedaab6-8d0d-4d44-bf38-99b6dba13a4b
- **Configurado**: Autenticação OIDC (sem senhas!)

## Como Funciona

**Triggers**: Push ou PR para `main`

**Pipeline**:
1. 🏗️ Deploy Terraform (infraestrutura)
2. ⚡ Deploy Azure Functions (API)
3. 🌐 Deploy Static Web App (Frontend)
4. 🧪 Testes automáticos

## URLs dos Serviços

- **API**: https://redmine-ai-wmlha8wc-func.azurewebsites.net
- **Frontend**: https://icy-rock-09136280f.1.azurestaticapps.net
- **Health**: https://redmine-ai-wmlha8wc-func.azurewebsites.net/api/health
