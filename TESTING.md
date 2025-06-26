# 🧪 Script de Teste Local

Este script testa as funcionalidades básicas da aplicação localmente.

## 🏗️ Infraestrutura (Terraform)

### Validação da Configuração

```powershell
# Navegar para o diretório de infraestrutura
cd infra

# Validar sintaxe do Terraform
terraform validate

# Formatar código
terraform fmt -check

# Planejar deploy (sem aplicar)
terraform plan
```

### Deploy de Teste

```powershell
# Deploy usando script automatizado
.\deploy.ps1 -PlanOnly

# Ou deploy completo para teste
.\deploy.ps1 -AutoApprove
```

### Validação dos Recursos

```powershell
# Listar recursos criados
terraform state list

# Ver detalhes de um recurso
terraform state show azurerm_static_web_app.main

# Ver todos os outputs
terraform output
```

## Frontend (React)

```bash
# Entrar no diretório do frontend
cd src/frontend

# Instalar dependências (se não foi feito)
npm install

# Executar em modo desenvolvimento
npm run dev

# Verificar em http://localhost:5173
```

## Backend (Azure Functions)

```bash
# Entrar no diretório do backend
cd src/api

# Instalar dependências (se não foi feito)
npm install

# Construir o projeto
npm run build

# Executar Azure Functions localmente
npm run start

# Verificar em http://localhost:7071
```

## Testando Endpoints

### Health Check

```bash
curl http://localhost:7071/api/health
```

### Geração de Sugestão (Simulação)

```bash
curl -X POST http://localhost:7071/api/generate-suggestion \
  -H "Content-Type: application/json" \
  -d '{
    "texto": "Hoje trabalhei na correção de bugs no sistema de relatórios"
  }'
```

## Funcionalidades Testáveis

### ✅ No Frontend

- [x] Interface principal carrega
- [x] Formulário de entrada funciona
- [x] Sistema de abas funciona
- [x] Componentes de upload funcionam
- [x] Histórico é exibido (mock)
- [x] Responsividade

### ✅ No Backend

- [x] Health check responde
- [x] Função generateSuggestion (requer configuração OpenAI)
- [x] Função uploadEvidence (requer configuração Storage)
- [x] Função getActivityHistory (requer configuração Storage)
- [x] Função manageSuggestion (requer configuração Storage)

## Configurações Necessárias para Teste Completo

### 1. Azure OpenAI

- Criar recurso Azure OpenAI
- Obter endpoint e chave
- Configurar no Key Vault ou local.settings.json

### 2. Azure Storage

- Criar conta de storage
- Obter connection string
- Configurar no Key Vault ou local.settings.json

### 3. Azure Key Vault (Opcional para teste local)

- Criar Key Vault
- Configurar Managed Identity
- Adicionar secrets necessários

## Arquivo local.settings.json (Backend)

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=...",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "AZURE_OPENAI_ENDPOINT": "https://....openai.azure.com/",
    "AZURE_OPENAI_API_KEY": "sua-chave-openai",
    "AZURE_STORAGE_CONNECTION_STRING": "DefaultEndpointsProtocol=https;AccountName=...",
    "KEY_VAULT_URI": "https://seu-keyvault.vault.azure.net/",
    "APPLICATION_INSIGHTS_CONNECTION_STRING": "InstrumentationKey=..."
  }
}
```

## Status dos Testes

### ✅ Testes Básicos

- [x] Compilação do frontend sem erros
- [x] Compilação do backend sem erros
- [x] Dependências instaladas corretamente
- [x] Estrutura de arquivos correta
- [x] Configurações de build funcionando

### 🔄 Testes de Integração (Requerem Azure)

- [ ] Conexão com Azure OpenAI
- [ ] Upload para Blob Storage
- [ ] Consultas ao Table Storage
- [ ] Autenticação via Key Vault
- [ ] Telemetria no Application Insights

### 🎯 Próximos Passos

1. Configurar ambiente Azure
2. Fazer deploy via `azd up`
3. Testar funcionalidades completas
4. Configurar monitoramento
5. Documentar resultados

---

**Última atualização**: ${new Date().toLocaleDateString('pt-BR')}
