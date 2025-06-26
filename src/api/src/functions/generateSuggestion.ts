import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { v4 as uuidv4 } from "uuid";
import { OpenAIService } from "../openai.service";
import ConfigService from "../config";
import { SuggestionResponse, HistoryEntry } from "../types";

export async function generateSuggestion(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log("Iniciando geração de sugestão");

  try {
    // Verificar método HTTP
    if (request.method !== "POST") {
      return {
        status: 405,
        jsonBody: { error: "Método não permitido" },
      };
    }

    // Parse do body da requisição
    let requestBody: any;
    try {
      const bodyText = await request.text();
      requestBody = JSON.parse(bodyText);
    } catch (error) {
      return {
        status: 400,
        jsonBody: { error: "Corpo da requisição inválido" },
      };
    }

    const { texto } = requestBody;

    if (!texto || typeof texto !== "string" || texto.trim().length === 0) {
      return {
        status: 400,
        jsonBody: {
          error: 'Campo "texto" é obrigatório e deve ser uma string não vazia',
        },
      };
    }

    // Gerar sugestão usando OpenAI
    const openAIService = new OpenAIService();
    const suggestion = await openAIService.generateSuggestion(texto.trim());

    // Gerar ID único e timestamp
    const id = uuidv4();
    const timestamp = new Date().toISOString();

    // Calcular confiança baseada na qualidade da entrada
    const confidence = calculateConfidence(texto.trim());

    // Salvar no histórico
    await saveToHistory(id, texto.trim(), suggestion, timestamp);

    const response: SuggestionResponse = {
      sugestao: suggestion,
      confianca: confidence,
      timestamp,
      id,
    };

    context.log(
      `Sugestão gerada com sucesso. ID: ${id}, Confiança: ${confidence}%`
    );

    return {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
      jsonBody: response,
    };
  } catch (error) {
    context.error("Erro ao gerar sugestão:", error);

    const errorMessage =
      error instanceof Error ? error.message : "Erro desconhecido";

    return {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      jsonBody: {
        error: "Erro interno do servidor",
        details:
          process.env.NODE_ENV === "development" ? errorMessage : undefined,
      },
    };
  }
}

/**
 * Calcula a confiança baseada na qualidade do texto de entrada
 */
function calculateConfidence(texto: string): number {
  let confidence = 50; // Base

  // Adicionar pontos baseado no comprimento
  if (texto.length > 100) confidence += 20;
  if (texto.length > 200) confidence += 10;

  // Adicionar pontos por palavras-chave importantes
  const keywords = [
    "reunião",
    "teams",
    "horas",
    "lgpd",
    "análise",
    "gap",
    "infraestrutura",
    "servidor",
    "monitoramento",
    "zabbix",
    "treinamento",
    "curso",
    "capacitação",
    "auditoria",
  ];

  const foundKeywords = keywords.filter((keyword) =>
    texto.toLowerCase().includes(keyword)
  ).length;

  confidence += foundKeywords * 5;

  // Adicionar pontos por informações específicas
  if (texto.includes("durou") || texto.includes("duração")) confidence += 10;
  if (texto.includes("objetivo") || texto.includes("meta")) confidence += 5;
  if (texto.includes("participantes") || texto.includes("equipe"))
    confidence += 5;

  // Limitar entre 60 e 95
  return Math.min(95, Math.max(60, confidence));
}

/**
 * Salva a sugestão no histórico (Azure Table Storage)
 */
async function saveToHistory(
  id: string,
  input: string,
  suggestion: any,
  timestamp: string
): Promise<void> {
  try {
    const configService = ConfigService.getInstance();
    const tableClient = await configService.getTableClient();

    // Criar a tabela se não existir
    await tableClient.createTable().catch(() => {
      // Ignorar erro se a tabela já existir
    });

    const historyEntry: HistoryEntry = {
      partitionKey: "suggestions",
      rowKey: id,
      id,
      input,
      suggestion,
      approved: false,
      createdAt: timestamp,
    };

    await tableClient.createEntity(historyEntry);
  } catch (error) {
    console.error("Erro ao salvar no histórico:", error);
    // Não falhar a requisição por erro de logging
  }
}

// Registrar a função
app.http("generateSuggestion", {
  methods: ["POST", "OPTIONS"],
  route: "generate-suggestion",
  authLevel: "anonymous",
  handler: generateSuggestion,
});
