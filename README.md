# Redmine AI Reporter - Azure Deployment (FREE TIER PROTECTED)

🤖 **Sistema automatizado de relatórios para Redmine usando Azure OpenAI**  
💰 **100% FREE TIER** - Gasto zero no Azure  
🔒 **PROTEGIDO** - Recursos críticos não são recriados nos deploys

## 🎯 **Arquitetura Otimizada**

### **Frontend (React + Vite)**

- 📱 Interface moderna e responsiva
- ⚡ Build otimizado com Vite
- 🎨 Tailwind CSS para estilização
- 🔗 Integração automática com API

### **Backend (Azure Functions + Node.js)**

- 🚀 Serverless com Azure Functions (FREE tier)
- 🤖 Integração com Azure OpenAI GPT-4o-mini
- 🔐 Autenticação via Managed Identity
- 📊 Logs via Application Insights

### **Infraestrutura (Terraform + FREE Tier)**

- 🏗️ Infrastructure as Code com Terraform
- 💰 Todos os recursos em FREE tier
- 🔒 Proteções contra recriação de recursos críticos
- 🔑 API Keys preservadas no Key Vault

## 🚀 **Deploy Automatizado**

### **CI/CD Pipeline (GitHub Actions)**

```yaml
name: Deploy to Azure (FREE TIER PROTECTED)
```

**Características:**

- ✅ Deploy automático no push para `master`
- 🔒 Recursos críticos protegidos contra recriação
- 💰 Uso exclusivo de recursos FREE tier
- 🧪 Testes automatizados pós-deploy
- 📊 Validação completa da aplicação

### **Recursos Azure (FREE Tier)**

| Recurso              | Tipo       | Tier        | Custo        |
| -------------------- | ---------- | ----------- | ------------ |
| Function App         | Compute    | Consumption | FREE         |
| Static Web App       | Frontend   | Free        | FREE         |
| Azure OpenAI         | AI         | S0          | FREE credits |
| Key Vault            | Security   | Standard    | FREE         |
| Application Insights | Monitoring | Free        | FREE         |
| Storage Account      | Storage    | LRS         | FREE         |
| Log Analytics        | Logs       | Free        | FREE         |

## 🔧 **Setup Inicial**

### **1. Pré-requisitos**

```bash
# Azure CLI
az --version

# Terraform
terraform --version

# Node.js 20+
node --version
```

### **2. Configuração Azure**

```bash
# Login no Azure
az login

# Criar Service Principal para GitHub Actions
az ad sp create-for-rbac --name "redmine-ai-github-actions" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth
```

### **3. Secrets GitHub**

No GitHub, configure em **Settings > Secrets**:

- `AZURE_CREDENTIALS`: Output do comando acima

### **4. Deploy**

```bash
# Push para master dispara deploy automático
git push origin master
```

## 🔒 **Proteções Implementadas**

### **Terraform Lifecycle Protection**

```hcl
# Azure OpenAI protegido
resource "azurerm_cognitive_account" "openai" {
  lifecycle {
    prevent_destroy = true
    ignore_changes = [custom_subdomain_name, tags]
  }
}

# Key Vault protegido
resource "azurerm_key_vault" "main" {
  lifecycle {
    prevent_destroy = true
    ignore_changes = [tags]
  }
}
```

### **Benefícios**

- 🔑 **API Keys preservadas** - Não são recriadas nos deploys
- 💾 **Dados mantidos** - Secrets no Key Vault preservados
- ⚡ **Deploy rápido** - Apenas atualiza código, não infraestrutura
- 💰 **Custo zero** - Evita cobrança por recriação de recursos

## 📊 **Monitoramento**

### **URLs de Produção**

- **Frontend**: `https://{swa-name}.azurestaticapps.net`
- **API**: `https://{function-name}.azurewebsites.net`
- **Health Check**: `{api-url}/api/health`

### **Logs e Métricas**

- Application Insights dashboard
- Function App logs
- Static Web App analytics
- Azure OpenAI usage metrics

## 🧪 **Testes**

### **Automáticos (CI/CD)**

- Health check da API
- Conectividade frontend ↔ API
- Validação do Azure OpenAI
- Verificação de recursos FREE tier

### **Manuais**

```bash
# Testar API local
cd src/api
npm start

# Testar frontend local
cd src/frontend
npm run dev
```

## 📁 **Estrutura do Projeto**

```
redmine-ai-reporter/
├── .github/workflows/
│   └── deploy-clean.yml          # CI/CD Pipeline protegido
├── infra/
│   ├── main.tf                   # Infraestrutura Terraform
│   ├── variables.tf              # Variáveis (FREE tier)
│   ├── outputs.tf                # Outputs para CI/CD
│   └── terraform.tfvars          # Configurações
├── src/
│   ├── api/                      # Azure Functions (Node.js)
│   └── frontend/                 # React + Vite + Tailwind
├── docs/                         # Documentação
├── azure.yaml                    # Configuração AZD
└── README.md                     # Este arquivo
```

## 💡 **Principais Vantagens**

### **✅ Custo Zero**

- Todos os recursos em FREE tier
- Sem surpresas na fatura Azure
- Monitoramento de custos automatizado

### **🔒 Segurança e Proteção**

- API Keys nunca são perdidas
- Recursos críticos protegidos
- Managed Identity para autenticação

### **⚡ Deploy Rápido**

- CI/CD totalmente automatizado
- Apenas código é atualizado nos deploys
- Validação automática pós-deploy

### **📊 Observabilidade**

- Logs centralizados
- Métricas de performance
- Monitoramento de custos

## 🆘 **Troubleshooting**

### **Erro 500 na API**

1. Verificar logs no Application Insights
2. Validar configurações do Azure OpenAI
3. Checar permissões da Managed Identity

### **Frontend não conecta à API**

1. Verificar variável `VITE_API_URL`
2. Validar CORS na Function App
3. Testar endpoint `/api/health`

### **Deploy falha**

1. Verificar secrets do GitHub
2. Validar quota do Azure
3. Checar logs do GitHub Actions

---

💡 **Desenvolvido com foco em FREE TIER, SEGURANÇA e AUTOMAÇÃO**
