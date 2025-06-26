# 🏗️ Guia Terraform - Redmine AI Reporter

Este guia fornece instruções detalhadas para deploy e gerenciamento da infraestrutura usando Terraform.

## 📋 **Pré-requisitos**

### **1. Instalar Terraform**

```powershell
# Windows (usando winget)
winget install Hashicorp.Terraform

# Verificar instalação
terraform version
```

### **2. Instalar Azure CLI**

```powershell
# Windows (usando winget)
winget install Microsoft.AzureCLI

# Login no Azure
az login
```

### **3. Configurar Terraform**

```powershell
# Navegar para o diretório de infraestrutura
cd infra

# Copiar arquivo de variáveis
copy terraform.tfvars.example terraform.tfvars

# Editar terraform.tfvars com seus valores
notepad terraform.tfvars
```

## 🚀 **Deploy Rápido**

### **Opção 1: Script Automático (Recomendado)**

```powershell
# Deploy completo com validação
.\deploy.ps1

# Deploy automático (sem confirmações)
.\deploy.ps1 -AutoApprove

# Apenas planejar (sem aplicar)
.\deploy.ps1 -PlanOnly
```

### **Opção 2: Manual**

```powershell
cd infra

# 1. Inicializar Terraform
terraform init

# 2. Validar configuração
terraform validate

# 3. Planejar mudanças
terraform plan

# 4. Aplicar mudanças
terraform apply

# 5. Ver outputs
terraform output
```

## 🔧 **Comandos Úteis**

### **Visualização**

```powershell
# Ver estado atual
terraform show

# Listar recursos
terraform state list

# Ver outputs
terraform output

# Ver output específico
terraform output AZURE_FUNCTION_APP_URL
```

### **Gerenciamento**

```powershell
# Atualizar providers
terraform init -upgrade

# Reformatar código
terraform fmt

# Validar sintaxe
terraform validate

# Ver gráfico de dependências
terraform graph | dot -Tsvg > graph.svg
```

### **Debugging**

```powershell
# Log detalhado
$env:TF_LOG="DEBUG"
terraform plan

# Reset do log
$env:TF_LOG=""
```

## 📁 **Estrutura dos Arquivos**

```
infra/
├── main.tf                 # Recursos principais
├── variables.tf            # Definições de variáveis
├── outputs.tf              # Outputs da infraestrutura
├── backend.tf              # Configuração do backend (comentado)
├── terraform.tfvars.example # Exemplo de variáveis
├── terraform.tfvars        # Suas variáveis (não versionado)
└── .gitignore             # Ignora arquivos sensíveis
```

## ⚙️ **Configuração de Variáveis**

### **Arquivo terraform.tfvars**

```hcl
# Obrigatório
resource_group_name = "rg-redmine-ai-reporter-dev"

# Opcionais
environment_name = "dev"
location         = "East US"
resource_prefix  = "redmine-ai"
app_name         = "redmine-ai-reporter"
```

### **Variáveis de Ambiente**

```powershell
# Alternativa para variáveis sensíveis
$env:TF_VAR_resource_group_name="rg-redmine-ai-reporter-dev"
```

## 🔒 **Estado Remoto (Produção)**

Para ambientes de produção, configure o estado remoto:

### **1. Criar Storage Account**

```powershell
# Criar resource group para estado
az group create --name rg-terraform-state --location "East US"

# Criar storage account
az storage account create --name terraformstate$(Get-Random) --resource-group rg-terraform-state --location "East US" --sku Standard_LRS

# Criar container
az storage container create --name tfstate --account-name <STORAGE-ACCOUNT-NAME>
```

### **2. Configurar Backend**

Descomente e configure o arquivo `backend.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "terraformstate<unique_suffix>"
    container_name       = "tfstate"
    key                  = "redmine-ai-reporter.terraform.tfstate"
  }
}
```

### **3. Inicializar com Backend**

```powershell
terraform init
```

## 🏷️ **Tags e Recursos**

Todos os recursos são criados com tags consistentes:

- `azd-env-name`: Nome do ambiente
- `app-name`: Nome da aplicação
- `project`: redmine-ai-reporter
- `cost-center`: development
- `environment`: Nome do ambiente

## 📊 **Outputs Disponíveis**

| Output                             | Descrição                          |
| ---------------------------------- | ---------------------------------- |
| `AZURE_STATIC_WEB_APP_URL`         | URL da aplicação web               |
| `AZURE_FUNCTION_APP_URL`           | URL da API                         |
| `AZURE_KEY_VAULT_URI`              | URI do Key Vault                   |
| `AZURE_STORAGE_ACCOUNT_NAME`       | Nome da conta de storage           |
| `AZURE_MANAGED_IDENTITY_CLIENT_ID` | Client ID da identidade gerenciada |

## 🧹 **Limpeza**

### **Destruir Recursos**

```powershell
# CUIDADO: Isso remove toda a infraestrutura!
terraform destroy

# Com confirmação automática
terraform destroy -auto-approve
```

### **Limpar Estado Local**

```powershell
# Remove arquivos locais do Terraform
Remove-Item .terraform -Recurse -Force
Remove-Item .terraform.lock.hcl -Force
Remove-Item terraform.tfstate* -Force
```

## 🔍 **Troubleshooting**

### **Problemas Comuns**

1. **Erro de autenticação**

   ```powershell
   az login
   az account set --subscription <SUBSCRIPTION-ID>
   ```

2. **Resource Group não existe**

   ```powershell
   az group create --name <RESOURCE-GROUP-NAME> --location "East US"
   ```

3. **Nomes de recursos duplicados**

   - Os nomes são únicos usando random string
   - Se necessário, rode `terraform destroy` e `terraform apply` novamente

4. **Falha no provider lock**
   ```powershell
   terraform init -upgrade
   ```

### **Logs e Debug**

```powershell
# Habilitar logs detalhados
$env:TF_LOG="DEBUG"
$env:TF_LOG_PATH="terraform.log"

# Executar comando com logs
terraform apply

# Desabilitar logs
$env:TF_LOG=""
Remove-Variable TF_LOG_PATH
```

## 🎯 **Próximos Passos**

Após o deploy bem-sucedido:

1. ✅ Configure as secrets do GitHub Actions
2. ✅ Configure o Azure OpenAI no Key Vault
3. ✅ Teste a aplicação
4. ✅ Configure monitoramento
5. ✅ Documente a infraestrutura específica

## 📚 **Recursos Adicionais**

- [Documentação oficial do Terraform](https://developer.hashicorp.com/terraform/docs)
- [Provider AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
