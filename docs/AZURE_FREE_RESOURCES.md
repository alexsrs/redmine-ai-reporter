# Azure Free Resources - Redmine AI Reporter

Este documento detalha todos os recursos Azure utilizados no projeto e suas configurações otimizadas para **maximizar o uso gratuito**.

## 🆓 Recursos Gratuitos Utilizados

### 1. Azure Static Web Apps (Free Tier)

- **SKU**: `Free`
- **Limites Gratuitos**:
  - ✅ 100GB de bandwidth por mês
  - ✅ Domínios customizados
  - ✅ SSL automático
  - ✅ 2 ambientes de staging
- **Custo**: **R$ 0,00/mês**

### 2. Azure Functions (Consumption Plan)

- **SKU**: `Y1` (Consumption)
- **Limites Gratuitos**:
  - ✅ 1 milhão de execuções gratuitas por mês
  - ✅ 400.000 GB-segundos de consumo gratuito
  - ✅ Paga apenas pelo que usar além do limite
- **Custo**: **R$ 0,00/mês** (dentro dos limites)

### 3. Azure Storage Account (Standard LRS)

- **SKU**: `Standard_LRS`
- **Limites Gratuitos**:
  - ✅ 5GB de armazenamento LRS gratuito (primeiros 12 meses)
  - ✅ 20.000 operações de leitura gratuitas
  - ✅ 10.000 operações de escrita gratuitas
- **Otimizações**:
  - Retenção de blob soft delete: 7 dias (mínimo)
  - Tier "Hot" para acesso frequente
- **Custo**: **R$ 0,00/mês** (primeiros 12 meses)

### 4. Azure Key Vault (Standard)

- **SKU**: `Standard`
- **Limites Gratuitos**:
  - ✅ 10.000 transações gratuitas por mês
  - ✅ Certificados e chaves ilimitados
- **Otimizações**:
  - Soft delete retention: 7 dias (mínimo)
  - Purge protection desabilitado
- **Custo**: **R$ 0,00/mês** (dentro dos limites)

### 5. Application Insights

- **Tipo**: `web`
- **Limites Gratuitos**:
  - ✅ 1GB de dados de telemetria por mês
  - ✅ 90 dias de retenção
- **Custo**: **R$ 0,00/mês** (dentro dos limites)

### 6. Log Analytics Workspace

- **SKU**: `PerGB2018`
- **Limites Gratuitos**:
  - ✅ 5GB de dados por mês
  - ✅ 31 dias de retenção
- **Otimizações**:
  - Daily quota: 1GB (previne cobranças inesperadas)
  - Retenção: 30 dias
- **Custo**: **R$ 0,00/mês** (dentro dos limites)

### 7. User-Assigned Managed Identity

- **Custo**: **R$ 0,00** (sem cobrança adicional)

### 8. Role Assignments (RBAC)

- **Custo**: **R$ 0,00** (sem cobrança adicional)

## 💰 Resumo de Custos

| Recurso              | Tier         | Custo Mensal Estimado |
| -------------------- | ------------ | --------------------- |
| Static Web App       | Free         | R$ 0,00               |
| Azure Functions      | Consumption  | R$ 0,00\*             |
| Storage Account      | Standard LRS | R$ 0,00\*\*           |
| Key Vault            | Standard     | R$ 0,00\*             |
| Application Insights | -            | R$ 0,00\*             |
| Log Analytics        | PerGB2018    | R$ 0,00\*             |
| Managed Identity     | -            | R$ 0,00               |
| **TOTAL**            |              | **R$ 0,00\***         |

\* _Dentro dos limites gratuitos_  
\*\* _Primeiros 12 meses com conta gratuita_  
\*\*\* _Para uso típico de desenvolvimento e demonstração_

## ⚠️ Alertas de Monitoramento

### Limites a Monitorar:

1. **Azure Functions**: 1M execuções/mês
2. **Storage**: 5GB de dados
3. **Application Insights**: 1GB telemetria/mês
4. **Log Analytics**: 5GB logs/mês
5. **Key Vault**: 10K transações/mês

### Recomendações:

- Configure alertas no Azure Monitor para cada limite
- Monitore uso mensal através do Cost Management
- Otimize código para reduzir execuções desnecessárias
- Implemente log levels apropriados para controlar volume

## 🔧 Configurações de Otimização

### Storage Account:

```terraform
account_tier             = "Standard"
account_replication_type = "LRS"  # Mais barato
access_tier              = "Hot"  # Para acesso frequente
```

### Log Analytics:

```terraform
sku               = "PerGB2018"
retention_in_days = 30
daily_quota_gb    = 1  # Previne cobranças extras
```

### Key Vault:

```terraform
sku_name                   = "standard"
soft_delete_retention_days = 7      # Mínimo
purge_protection_enabled   = false  # Evita custos de retenção
```

### Function App:

```terraform
sku_name = "Y1"  # Consumption plan - paga por uso
```

## 🚀 Upgrade Path

Caso precise escalar além dos limites gratuitos:

1. **Static Web App**: Standard ($9/mês) - para mais ambientes
2. **Functions**: Premium ($13.77/mês) - para melhor performance
3. **Storage**: Pago por GB adicional
4. **Application Insights**: $2.88/GB adicional
5. **Log Analytics**: $2.76/GB adicional

## 📊 Monitoramento de Custos

### Scripts Úteis:

```bash
# Verificar custos atuais
az consumption usage list --start-date 2024-01-01 --end-date 2024-01-31

# Alertas de orçamento
az consumption budget create --budget-name "redmine-ai-budget" --amount 10 --category Cost
```

### Dashboards Recomendados:

- Azure Cost Management
- Application Insights Usage
- Storage Account Metrics
- Function App Consumption

---

**⚡ Conclusão**: Esta configuração permite executar o Redmine AI Reporter com **custo zero** para cargas de trabalho típicas de desenvolvimento e demonstração, aproveitando ao máximo os recursos gratuitos do Azure.
