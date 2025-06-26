# 📋 Plano Detalhado - Próximos Passos do Projeto

## 🎯 **Status Atual (26 de Junho de 2025 - 18:45)**

### ✅ **Conquistas Realizadas:**

- **Infraestrutura Terraform:** 100% funcional e deployada
- **Function App:** Recriada e respondendo (Status 200)
- **Frontend React:** Totalmente funcional com CSS Tailwind
- **Azure OpenAI:** Integrado com gpt-4o-mini
- **Key Vault:** Configurado com secrets
- **Storage Account:** Funcionando
- **Application Insights:** Monitoramento ativo

### 🔍 **Problema Atual:**

- Functions são deployadas com sucesso, mas não aparecem na listagem do Azure CLI
- Endpoint `/api/health` retorna 404 (função não registrada)

---

## 🚀 **FASE 1: Resolver Registro das Azure Functions**

### **Passo 1.1: Diagnóstico Avançado (Prioridade ALTA)**

- [ ] **Verificar logs detalhados da Function App:**

  ```powershell
  az functionapp logs tail --name redmine-ai-wmlha8wc-func --resource-group rg-redmine-ai-reporter-dev
  ```

- [ ] **Analisar configurações específicas do runtime:**

  ```powershell
  az functionapp config show --name redmine-ai-wmlha8wc-func --resource-group rg-redmine-ai-reporter-dev
  ```

- [ ] **Verificar se o app.js está sendo executado:**
  - Adicionar mais logs de debug
  - Testar com estrutura ainda mais simples

### **Passo 1.2: Teste com Estrutura Mínima (Prioridade ALTA)**

- [ ] **Criar versão ultra-simplificada:**

  - Apenas uma função health em um único arquivo
  - Usar estrutura oficial da documentação Microsoft
  - Testar sem TypeScript (apenas JavaScript puro)

- [ ] **Validar package.json:**
  - Verificar se main aponta para o arquivo correto
  - Confirmar dependências mínimas necessárias

### **Passo 1.3: Deploy e Teste Iterativo (Prioridade ALTA)**

- [ ] **Deploy da versão simplificada:**

  ```powershell
  npx func azure functionapp publish redmine-ai-wmlha8wc-func --javascript --force
  ```

- [ ] **Teste imediato do endpoint:**

  ```powershell
  curl https://redmine-ai-wmlha8wc-func.azurewebsites.net/api/health
  ```

- [ ] **Verificar listagem das funções:**
  ```powershell
  az functionapp function list --name redmine-ai-wmlha8wc-func --resource-group rg-redmine-ai-reporter-dev
  ```

---

## 🔧 **FASE 2: Expandir Funcionalidades Backend**

### **Passo 2.1: Adicionar Funções Graduais (Prioridade MÉDIA)**

- [ ] **Após health funcionar, adicionar uma função por vez:**
  1. `generateSuggestion` - Integração com Azure OpenAI
  2. `manageSuggestion` - Gestão de sugestões
  3. `getActivityHistory` - Histórico de atividades
  4. `uploadEvidence` - Upload de evidências

### **Passo 2.2: Integração com Azure OpenAI (Prioridade MÉDIA)**

- [ ] **Testar conexão direta com Azure OpenAI:**
  - Usar Managed Identity para autenticação
  - Validar endpoint e modelo gpt-4o-mini
  - Implementar tratamento de erros robusto

### **Passo 2.3: Integração com Key Vault (Prioridade MÉDIA)**

- [ ] **Implementar acesso aos secrets:**
  - REDMINE_URL
  - REDMINE_API_KEY
  - Outros secrets necessários

---

## 🌐 **FASE 3: Integração Frontend-Backend**

### **Passo 3.1: Conectar Frontend com Backend (Prioridade ALTA)**

- [ ] **Atualizar variáveis do frontend:**

  - Confirmar URL da API em `.env.production`
  - Testar endpoints do frontend

- [ ] **Implementar tratamento de erros:**
  - Loading states
  - Error boundaries
  - Retry mechanisms

### **Passo 3.2: Teste de Integração Completa (Prioridade ALTA)**

- [ ] **Fluxo completo da aplicação:**
  1. Login/autenticação
  2. Busca de issues do Redmine
  3. Geração de sugestões via AI
  4. Aprovação e envio de comentários
  5. Histórico de atividades

---

## 📊 **FASE 4: Testes e Validação**

### **Passo 4.1: Testes Funcionais (Prioridade MÉDIA)**

- [ ] **Testes de cada endpoint:**
  - Health check
  - Geração de sugestões
  - Upload de evidências
  - Histórico de atividades

### **Passo 4.2: Testes de Integração (Prioridade MÉDIA)**

- [ ] **Integração com Redmine real:**
  - Configurar instância de teste do Redmine
  - Validar API calls
  - Testar criação/atualização de issues

### **Passo 4.3: Testes de Performance (Prioridade BAIXA)**

- [ ] **Otimização e monitoramento:**
  - Tempo de resposta das Azure Functions
  - Uso de recursos
  - Logs de Application Insights

---

## 🔐 **FASE 5: Segurança e Produção**

### **Passo 5.1: Hardening de Segurança (Prioridade MÉDIA)**

- [ ] **Revisão de configurações:**
  - CORS mais restritivo
  - Autenticação robusta
  - Validação de inputs

### **Passo 5.2: Documentação Final (Prioridade BAIXA)**

- [ ] **Documentação completa:**
  - README atualizado
  - Guia de deployment
  - Troubleshooting guide
  - API documentation

---

## ⏰ **Timeline Estimado**

### **Hoje (26/06/2025):**

- ✅ Resolver problema de registro das funções (Fase 1)
- ✅ Testar endpoint health funcionando

### **Próximos 1-2 dias:**

- ✅ Expandir funcionalidades backend (Fase 2)
- ✅ Integração frontend-backend (Fase 3)

### **Próximos 3-5 dias:**

- ✅ Testes completos (Fase 4)
- ✅ Finalização e documentação (Fase 5)

---

## 🎯 **Critérios de Sucesso**

### **Sucesso Imediato (Hoje):**

- [ ] Endpoint `/api/health` retorna 200 com JSON
- [ ] Função aparece na listagem do Azure CLI
- [ ] Logs mostram função sendo executada

### **Sucesso Completo (Semana):**

- [ ] Todas as funções operacionais
- [ ] Frontend conectado ao backend
- [ ] Integração com Redmine funcionando
- [ ] Geração de relatórios AI operacional

---

## 🔧 **Comandos de Referência Rápida**

```powershell
# Deploy das functions
cd f:\SOURCE_CODE\redmine-ai-reporter\src\api
npx func azure functionapp publish redmine-ai-wmlha8wc-func --javascript

# Testar endpoint
Invoke-WebRequest -Uri "https://redmine-ai-wmlha8wc-func.azurewebsites.net/api/health"

# Verificar funções
az functionapp function list --name redmine-ai-wmlha8wc-func --resource-group rg-redmine-ai-reporter-dev

# Ver logs
az functionapp logs tail --name redmine-ai-wmlha8wc-func --resource-group rg-redmine-ai-reporter-dev
```

---

**Próxima Ação Imediata:** Executar Fase 1, Passo 1.1 - Diagnóstico Avançado dos logs da Function App
