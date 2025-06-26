# 🔑 Configuração do Key Vault - Azure OpenAI Service e Redmine

## ✅ Status Atual

Os secrets foram configurados com sucesso no Key Vault `redmine-ai-wmlha8wc-kv`.

### **🎯 Azure OpenAI Service (CONFIGURADO AUTOMATICAMENTE):**

- ✅ **AZURE-OPENAI-ENDPOINT**: `https://redmine-ai-wmlha8wc-openai.openai.azure.com/`
- ✅ **AZURE-OPENAI-MODEL**: `gpt-4o-mini`
- ✅ **Managed Identity configurada** com permissões OpenAI

### **🔧 Configuração Manual Restante:**

- ⚠️ **REDMINE-BASE-URL**: `https://your-redmine-instance.com` (PLACEHOLDER)
- ⚠️ **REDMINE-API-KEY**: `your-redmine-api-key-here` (PLACEHOLDER)

### **📋 Secrets Legados (Opcional - para OpenAI API direta):**

- ✅ **OPENAI-ENDPOINT**: `https://api.openai.com/v1`
- ✅ **OPENAI-MODEL**: `gpt-3.5-turbo`
- ⚠️ **OPENAI-API-KEY**: `sk-your-openai-api-key-here-replace-this-value` (PLACEHOLDER)

## 🔧 Próximos Passos - Configuração Obrigatória

### **✨ NOVIDADE: Azure OpenAI Service Já Configurado!**

**Não precisa mais de API Key externa!** 🎉

O Azure OpenAI Service foi configurado automaticamente com:

- **Endpoint**: `https://redmine-ai-wmlha8wc-openai.openai.azure.com/`
- **Modelo**: `gpt-4o-mini` (deployed)
- **Autenticação**: Managed Identity (sem chaves necessárias)
- **Custo**: Pay-per-use (mais barato que API direta)

### **⚠️ Configuração Manual Apenas para Redmine:**

```bash
# 1. Substitua pela URL real do seu Redmine
az keyvault secret set --vault-name "redmine-ai-wmlha8wc-kv" --name "REDMINE-BASE-URL" --value "https://seu-redmine.com"

# 2. Substitua pela sua chave API do Redmine
az keyvault secret set --vault-name "redmine-ai-wmlha8wc-kv" --name "REDMINE-API-KEY" --value "sua-chave-redmine-aqui"
```

### **🎯 Para Testes Rápidos (Opcional):**

Se você quiser testar a aplicação sem Redmine próprio, pode usar:

```bash
# Configuração de teste com Redmine demo
az keyvault secret set --vault-name "redmine-ai-wmlha8wc-kv" --name "REDMINE-BASE-URL" --value "https://demo.redmine.org"
az keyvault secret set --vault-name "redmine-ai-wmlha8wc-kv" --name "REDMINE-API-KEY" --value "demo-api-key"
```

**Como obter sua Redmine API Key:**

1. Acesse seu Redmine
2. Vá em "My account" (Minha conta)
3. Clique na aba "API access key"
4. Clique em "Show" para revelar ou "Reset" para gerar nova
5. Copie a chave gerada

### 3. Verificar Configurações

```bash
# Listar todos os secrets
az keyvault secret list --vault-name "redmine-ai-wmlha8wc-kv" --query "[].name" --output table

# Verificar um secret específico (sem mostrar o valor)
az keyvault secret show --vault-name "redmine-ai-wmlha8wc-kv" --name "OPENAI-API-KEY" --query "name"
```

## 🔐 Segurança e Permissões

### Permissões Configuradas:

- **Managed Identity** (`redmine-ai-wmlha8wc-mi`):
  - `Get` e `List` secrets (para a aplicação acessar)
- **Usuário Atual** (`alexsrsouza@hotmail.com`):
  - `Get`, `List`, `Set`, `Delete` secrets (para gerenciamento)

### URLs dos Recursos:

- **Key Vault**: https://redmine-ai-wmlha8wc-kv.vault.azure.net/
- **Portal Azure**: https://portal.azure.com/#@b0864049-6d5c-4766-83a4-893358eaf2a5/resource/subscriptions/e6cf6630-8f1c-406d-a232-31c0edf55c2a/resourceGroups/rg-redmine-ai-reporter-dev/providers/Microsoft.KeyVault/vaults/redmine-ai-wmlha8wc-kv

## 💡 Configurações Opcionais

### Alterar Modelo OpenAI (Opcional):

```bash
# Para usar GPT-4 (mais caro, mas melhor qualidade)
az keyvault secret set --vault-name "redmine-ai-wmlha8wc-kv" --name "OPENAI-MODEL" --value "gpt-4"

# Para usar GPT-4 Turbo (custo-benefício)
az keyvault secret set --vault-name "redmine-ai-wmlha8wc-kv" --name "OPENAI-MODEL" --value "gpt-4-turbo-preview"

# Para manter GPT-3.5 Turbo (mais barato)
az keyvault secret set --vault-name "redmine-ai-wmlha8wc-kv" --name "OPENAI-MODEL" --value "gpt-3.5-turbo"
```

### Secrets Adicionais (Conforme Necessário):

```bash
# Configurações de timeout
az keyvault secret set --vault-name "redmine-ai-wmlha8wc-kv" --name "REQUEST-TIMEOUT" --value "30000"

# Configurações de rate limiting
az keyvault secret set --vault-name "redmine-ai-wmlha8wc-kv" --name "MAX-REQUESTS-PER-MINUTE" --value "60"
```

## 🚨 Importante

1. **Nunca commite chaves API** no código fonte
2. **Use sempre o Key Vault** para secrets sensíveis
3. **Monitore o uso** das APIs para evitar custos excessivos
4. **Revogue chaves antigas** quando necessário

## 📝 Próximos Passos

Após configurar os secrets:

1. ✅ Deploy do backend (Azure Functions)
2. ✅ Deploy do frontend (Static Web App)
3. ✅ Testes de integração
4. ✅ Validação do monitoramento

---

**Status**: � **AZURE OPENAI CONFIGURADO**  
**Pendente**: Apenas configurações do Redmine (opcional para testes)  
**Última Atualização**: 26 de junho de 2025

## 🎯 Vantagens do Azure OpenAI Service:

✅ **Mais Seguro**: Autenticação via Managed Identity  
✅ **Mais Barato**: Pay-per-use sem taxa fixa  
✅ **Mais Rápido**: Latência menor (hospedado na Azure)  
✅ **Compliance**: Totalmente dentro do Azure  
✅ **Sem Chaves**: Não precisa gerenciar API Keys

**A aplicação está PRONTA para usar IA!** 🚀
