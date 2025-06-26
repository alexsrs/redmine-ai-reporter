# 🤖 Redmine AI Reporter

![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)
![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)

> 🚀 **IA para análise de atividades e preenchimento automático no Redmine usando Azure AI Foundry**

Sistema inteligente que analisa descrições de atividades em linguagem natural e gera automaticamente sugestões de relatórios formatados para o Redmine, otimizado para o ambiente da **SEAP-RJ**.

## 📋 **Funcionalidades**

- 🧠 **Análise Inteligente**: Processa atividades descritas em linguagem natural
- 📝 **Geração Automática**: Cria relatórios estruturados para o Redmine
- 🎯 **Otimizado para SEAP-RJ**: Templates específicos para atividades da Secretaria
- 💾 **Histórico**: Armazena e gerencia sugestões anteriores
- 🔒 **Segurança**: Integração com Azure Key Vault e Managed Identity
- 📱 **Interface Moderna**: Frontend responsivo com React + TypeScript
- ☁️ **Cloud-Native**: 100% hospedado no Azure usando serviços gratuitos
- 🏗️ **Infrastructure as Code**: Provisionamento com Terraform

## 🏗️ **Arquitetura**

```
┌─────────────────────────────────────────────────────────┐
│                     🌐 Azure Static Web Apps            │
│                     (Frontend - React)                 │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                  ⚡ Azure Functions                    │
│                  (Backend - Node.js)                   │
└─────────────────────┬───────────────────────────────────┘
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│   🤖 Azure  │ │  📦 Storage │ │  🔐 Key     │
│   OpenAI    │ │   Account   │ │   Vault     │
│             │ │             │ │             │
└─────────────┘ └─────────────┘ └─────────────┘
```

### **Serviços Azure Utilizados (💰 100% GRATUITO)**

| Serviço                  | Propósito                | Tier                     | Custo Mensal     |
| ------------------------ | ------------------------ | ------------------------ | ---------------- |
| **Static Web Apps**      | Frontend React           | Free                     | **R$ 0,00**      |
| **Azure Functions**      | API Backend              | Consumption (Free)       | **R$ 0,00\***    |
| **Storage Account**      | Logs e evidências        | LRS (5GB Free)           | **R$ 0,00\***    |
| **Key Vault**            | Gerenciamento de secrets | Standard (10k ops/month) | **R$ 0,00\***    |
| **Application Insights** | Monitoramento            | 1GB/month free           | **R$ 0,00\***    |
| **Log Analytics**        | Logs centralizados       | 5GB/month free           | **R$ 0,00\***    |
| **Azure OpenAI**         | Geração de relatórios    | Pay-per-use              | ~R$ 5-10/mês\*\* |

> \* _Dentro dos limites gratuitos para uso de desenvolvimento/demonstração_  
> \*\* _Apenas Azure OpenAI tem custo, mas muito baixo para uso típico_

📊 **[Ver detalhes completos dos recursos gratuitos](docs/AZURE_FREE_RESOURCES.md)**

## 🚀 **Deploy Rápido**

### **Pré-requisitos**

- Node.js 20+
- Azure CLI
- Azure Developer CLI (azd)
- Conta Azure com acesso ao Azure OpenAI

### **1. Clone e Setup**

```bash
git clone https://github.com/alexsandro-ribeiro-dev/redmine-ai-reporter.git
cd redmine-ai-reporter

# Instalar Azure Developer CLI
winget install microsoft.azd
```

### **2. Deploy com Terraform**

```bash
# Opção 1: Script automático (recomendado)
./deploy.ps1

# Opção 2: Manual
cd infra
terraform init
terraform plan
terraform apply

# Opção 3: Usar AZD (se ainda configurado)
azd auth login
azd init
azd up
```

### **3. Configurar Azure OpenAI**

```bash
# Após o deploy, adicionar as chaves no Key Vault
az keyvault secret set --vault-name <VAULT-NAME> --name "AZURE-OPENAI-ENDPOINT" --value "<SEU-ENDPOINT>"
az keyvault secret set --vault-name <VAULT-NAME> --name "AZURE-OPENAI-API-KEY" --value "<SUA-CHAVE>"
```

## 🛠️ **Desenvolvimento Local**

### **Frontend**

```bash
cd src/frontend
npm install
npm run dev
# Aplicação em http://localhost:3000
```

### **Backend**

```bash
cd src/api
npm install
npm run build
npm start
# API em http://localhost:7071
```

## 📚 **Como Usar**

### **1. Descreva sua Atividade**

```
Participei de uma reunião com o pessoal da LGPD para fazer um gap analysis.
A reunião durou 3 horas e foi feita no Teams. O objetivo era analisar a
conformidade dos dados da SEAP com a LGPD.
```

### **2. Receba a Sugestão Estruturada**

```json
{
  "data": "26/06/2025",
  "usuario": "Alex Sandro Ribeiro de Souza",
  "atividade": "Auditoria",
  "tarefa": "Catálogo #169302: Realizar Manutenção / Suporte (preventivo, perfectivo ou corretivo) de média complexidade (Alta plataforma)",
  "comentario": "Participação em reunião com equipe da Every Cyber Security sobre Gap Analysis. A atividade teve como foco avaliar o grau de conformidade da SEAP-RJ com os requisitos da Lei Geral de Proteção de Dados...",
  "horas": "3:00",
  "evidencias": "Reunião Teams, 26/06/2025, 14h–17h"
}
```

### **3. Revise e Aprove**

- ✏️ Edite campos conforme necessário
- ✅ Aprove e salve no histórico
- 📤 (Futuro) Envie diretamente para o Redmine

## 🎯 **Tipos de Atividade Suportados**

| Tipo               | Gatilhos                    | Exemplo                   |
| ------------------ | --------------------------- | ------------------------- |
| **Auditoria**      | reunião, lgpd, análise, gap | Análises de conformidade  |
| **Infraestrutura** | servidor, rede, storage     | Manutenção de servidores  |
| **Monitoramento**  | zabbix, acompanhamento      | Verificação de sistemas   |
| **Execução**       | tarefa, implementação       | Atividades práticas       |
| **Treinamento**    | curso, capacitação          | Palestras e certificações |

## 🔧 **Configuração Avançada**

### **Variáveis de Ambiente**

```bash
# Azure OpenAI
AZURE_OPENAI_ENDPOINT=https://seu-openai.openai.azure.com/
AZURE_OPENAI_API_KEY=sua-chave-aqui

# Armazenamento
AzureWebJobsStorage=DefaultEndpointsProtocol=https;AccountName=...

# Key Vault
KEY_VAULT_URI=https://seu-keyvault.vault.azure.net/

# Application Insights
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...
```

### **Customização do Prompt**

O prompt da IA pode ser customizado editando o arquivo `src/api/src/openai.service.ts`:

```typescript
private generatePrompt(activityText: string): string {
  // Personalize aqui para sua organização
  return `Você é um analista da SEAP-RJ...`;
}
```

## 📈 **Roadmap**

- [x] 🧠 Geração de relatórios com IA
- [x] 💾 Histórico de sugestões
- [x] 🎨 Interface moderna e responsiva
- [x] ☁️ Deploy automatizado no Azure
- [ ] 🔗 Integração direta com API do Redmine
- [ ] 📊 Dashboard de analytics
- [ ] 🔄 Workflow de aprovação
- [ ] 📱 Aplicativo mobile
- [ ] 🤖 Integração com Microsoft Teams

## 🧪 **Exemplo de Uso Completo**

```bash
# 1. Deploy da infraestrutura
./deploy.ps1

# 2. Teste do health check da API
curl https://sua-function-app.azurewebsites.net/api/health

# 3. Teste de geração de sugestão
curl -X POST https://sua-function-app.azurewebsites.net/api/generate-suggestion \
  -H "Content-Type: application/json" \
  -d '{"texto": "Reunião de planejamento da migração do datacenter, durou 2 horas"}'
```

## 🤝 **Contribuição**

1. 🍴 Fork do projeto
2. 🌿 Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. 💾 Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. 📤 Push para a branch (`git push origin feature/nova-funcionalidade`)
5. 🔄 Abra um Pull Request

## 📄 **Licença**

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👤 **Autor**

**Alex Sandro Ribeiro de Souza**

- 🏢 Secretaria de Estado de Administração Penitenciária - RJ
- 📧 Email: alex.sandro@seap.rj.gov.br
- 💼 LinkedIn: [alexsandro-ribeiro-dev](https://linkedin.com/in/alexsandro-ribeiro-dev)
- 🐙 GitHub: [@alexsandro-ribeiro-dev](https://github.com/alexsandro-ribeiro-dev)

---

<div align="center">

**⭐ Se este projeto foi útil para você, deixe uma estrela!**

_Construído com ❤️ usando Azure AI + React + TypeScript_

</div>
IA no Azure AI Foundry que analise suas atividades diárias e sugira automaticamente preenchimentos no Redmine com base no modelo fornecido
