import axios from "axios";
import { RedmineEntry, OpenAIResponse } from "./types";
import ConfigService from "./config";

export class OpenAIService {
  private configService = ConfigService.getInstance();

  /**
   * Gera prompt otimizado para o Azure OpenAI
   */
  private generatePrompt(activityText: string): string {
    const today = new Date().toLocaleDateString("pt-BR");

    return `Você é um analista da SEAP-RJ especializado em gerar relatórios para o Redmine. Com base na descrição de atividade fornecida, gere uma sugestão de lançamento de relatório seguindo EXATAMENTE o formato JSON especificado.

DESCRIÇÃO DA ATIVIDADE:
"${activityText}"

INSTRUÇÕES:
1. Use a data de hoje: ${today}
2. Use o usuário: "Alex Sandro Ribeiro de Souza"
3. Analise a atividade e categorize adequadamente
4. Gere comentários detalhados e profissionais
5. Estime as horas baseado na descrição

TIPOS DE ATIVIDADE PERMITIDOS:
- Auditoria: Para análises, conformidade, gap analysis
- Infraestrutura: Para servidores, redes, storage
- Monitoramento: Para acompanhamento de sistemas
- Execução: Para tarefas práticas e implementações
- Treinamento: Para capacitações e certificações

TAREFAS PADRÃO:
- "Catálogo #169302: Realizar Manutenção / Suporte (preventivo, perfectivo ou corretivo) de média complexidade (Alta plataforma)"
- "Catálogo #169301: Realizar Manutenção / Suporte (preventivo, perfectivo ou corretivo) de baixa complexidade (Alta plataforma)"
- "Catálogo #169303: Realizar Manutenção / Suporte (preventivo, perfectivo ou corretivo) de alta complexidade (Alta plataforma)"

FORMATO DE RESPOSTA (JSON válido):
{
  "data": "${today}",
  "usuario": "Alex Sandro Ribeiro de Souza",
  "atividade": "[Tipo da atividade]",
  "tarefa": "[Tarefa do catálogo]",
  "comentario": "[Comentário detalhado e profissional]",
  "horas": "[Tempo em formato HH:MM]",
  "evidencias": "[Evidências específicas]"
}

Responda APENAS com o JSON válido, sem texto adicional.`;
  }

  /**
   * Faz chamada para Azure OpenAI API
   */
  public async generateSuggestion(activityText: string): Promise<RedmineEntry> {
    try {
      const config = await this.configService.getConfig();

      if (!config.openAiEndpoint || !config.openAiApiKey) {
        throw new Error(
          "Azure OpenAI não configurado. Verificar variáveis de ambiente."
        );
      }

      const prompt = this.generatePrompt(activityText);

      // Simulação temporária (remover quando integrar com Azure OpenAI real)
      if (
        config.openAiApiKey === "mock" ||
        !config.openAiEndpoint.includes("openai.azure.com")
      ) {
        return this.generateMockResponse(activityText);
      }

      const response = await axios.post(
        `${config.openAiEndpoint}/openai/deployments/gpt-4/chat/completions?api-version=2024-02-15-preview`,
        {
          messages: [
            {
              role: "system",
              content:
                "Você é um assistente especializado em gerar relatórios para o Redmine da SEAP-RJ.",
            },
            {
              role: "user",
              content: prompt,
            },
          ],
          max_tokens: 1000,
          temperature: 0.3,
          top_p: 0.8,
        },
        {
          headers: {
            "Content-Type": "application/json",
            "api-key": config.openAiApiKey,
          },
          timeout: 30000,
        }
      );

      const content = response.data.choices[0]?.message?.content;
      if (!content) {
        throw new Error("Resposta inválida da Azure OpenAI");
      }

      // Parse da resposta JSON
      const jsonResponse = JSON.parse(content.trim()) as OpenAIResponse;

      return this.validateAndFormatResponse(jsonResponse);
    } catch (error) {
      console.error("Erro ao chamar Azure OpenAI:", error);

      // Fallback para resposta mock em caso de erro
      return this.generateMockResponse(activityText);
    }
  }

  /**
   * Valida e formata a resposta da OpenAI
   */
  private validateAndFormatResponse(response: OpenAIResponse): RedmineEntry {
    const today = new Date().toLocaleDateString("pt-BR");

    return {
      data: response.data || today,
      usuario: response.usuario || "Alex Sandro Ribeiro de Souza",
      atividade: response.atividade || "Execução",
      tarefa:
        response.tarefa ||
        "Catálogo #169302: Realizar Manutenção / Suporte (preventivo, perfectivo ou corretivo) de média complexidade (Alta plataforma)",
      comentario:
        response.comentario || "Atividade realizada conforme solicitação.",
      horas: response.horas || "1:00",
      evidencias: response.evidencias || "Registro de atividade",
    };
  }

  /**
   * Gera resposta mock para desenvolvimento/teste
   */
  private generateMockResponse(activityText: string): RedmineEntry {
    const today = new Date().toLocaleDateString("pt-BR");

    // Análise básica do texto para categorização
    const text = activityText.toLowerCase();
    let atividade = "Execução";
    let horas = "2:00";

    if (
      text.includes("reunião") ||
      text.includes("lgpd") ||
      text.includes("análise") ||
      text.includes("gap")
    ) {
      atividade = "Auditoria";
      if (text.includes("3 horas") || text.includes("3h")) {
        horas = "3:00";
      }
    } else if (
      text.includes("infraestrutura") ||
      text.includes("servidor") ||
      text.includes("rede")
    ) {
      atividade = "Infraestrutura";
    } else if (
      text.includes("monitoramento") ||
      text.includes("zabbix") ||
      text.includes("acompanhamento")
    ) {
      atividade = "Monitoramento";
      horas = "1:00";
    } else if (
      text.includes("treinamento") ||
      text.includes("curso") ||
      text.includes("capacitação")
    ) {
      atividade = "Treinamento";
    }

    return {
      data: today,
      usuario: "Alex Sandro Ribeiro de Souza",
      atividade,
      tarefa:
        "Catálogo #169302: Realizar Manutenção / Suporte (preventivo, perfectivo ou corretivo) de média complexidade (Alta plataforma)",
      comentario: `Atividade realizada conforme descrito: ${activityText.substring(
        0,
        200
      )}${
        activityText.length > 200 ? "..." : ""
      }. Trabalho executado seguindo as melhores práticas da SEAP-RJ.`,
      horas,
      evidencias: text.includes("teams")
        ? "Reunião Microsoft Teams"
        : "Registro de atividade no sistema",
    };
  }
}
