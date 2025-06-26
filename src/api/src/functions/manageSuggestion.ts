import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { TableClient } from "@azure/data-tables";
import ConfigService from "../config";

/**
 * Azure Function para aprovar ou rejeitar sugestões de atividades
 * Atualiza o status no histórico e opcionalmente envia para o Redmine
 */
export async function manageSuggestion(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log("Função manageSuggestion iniciada");

  // CORS preflight
  if (request.method === "OPTIONS") {
    return {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, PUT, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    };
  }

  if (!["POST", "PUT"].includes(request.method || "")) {
    return {
      status: 405,
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
      jsonBody: { error: "Método não permitido" },
    };
  }

  try {
    const configService = ConfigService.getInstance();
    const config = await configService.getConfig();

    const requestBody = await request.text();
    const { activityId, userId, action, feedback, redmineData } = JSON.parse(
      requestBody || "{}"
    );

    if (!activityId || !userId || !action) {
      return {
        status: 400,
        headers: { "Access-Control-Allow-Origin": "*" },
        jsonBody: { error: "activityId, userId e action são obrigatórios" },
      };
    }

    if (!["approve", "reject", "modify"].includes(action)) {
      return {
        status: 400,
        headers: { "Access-Control-Allow-Origin": "*" },
        jsonBody: { error: "action deve ser: approve, reject ou modify" },
      };
    }

    const tableClient = new TableClient(
      config.storageConnectionString,
      "RedmineAIHistory"
    );

    // Busca a atividade existente
    try {
      const entity = await tableClient.getEntity(userId, activityId);

      // Atualiza o status e metadados
      const updateData: any = {
        status:
          action === "approve"
            ? "approved"
            : action === "reject"
            ? "rejected"
            : "modified",
        updatedAt: new Date(),
        userFeedback: feedback || "",
        lastModifiedBy: userId,
      };

      if (action === "approve" && redmineData) {
        updateData.redmineTicketId = redmineData.ticketId;
        updateData.redmineStatus = "submitted";
        updateData.redmineSubmittedAt = new Date();
      }

      if (action === "modify" && redmineData) {
        // Atualiza os dados da sugestão com as modificações do usuário
        updateData.suggestion = JSON.stringify(redmineData.modifiedSuggestion);
        updateData.modifiedBy = userId;
        updateData.originalSuggestion = entity.suggestion; // Backup da sugestão original
      }

      await tableClient.updateEntity(
        {
          partitionKey: userId,
          rowKey: activityId,
          ...updateData,
        },
        "Merge"
      );

      let responseData: any = {
        success: true,
        activityId: activityId,
        action: action,
        status: updateData.status,
        message: `Sugestão ${
          action === "approve"
            ? "aprovada"
            : action === "reject"
            ? "rejeitada"
            : "modificada"
        } com sucesso`,
      };

      // Se aprovado, simula envio para Redmine (em produção seria integração real)
      if (action === "approve") {
        responseData.redmine = await simulateRedmineSubmission(
          redmineData,
          context
        );
      }

      context.log(`Atividade ${activityId} ${action} pelo usuário ${userId}`);

      return {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "POST, PUT, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization",
        },
        jsonBody: responseData,
      };
    } catch (entityError) {
      return {
        status: 404,
        headers: { "Access-Control-Allow-Origin": "*" },
        jsonBody: { error: "Atividade não encontrada" },
      };
    }
  } catch (error) {
    context.error("Erro ao gerenciar sugestão:", error);

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
 * Simula o envio para o Redmine (em produção seria integração real com API do Redmine)
 */
async function simulateRedmineSubmission(
  redmineData: any,
  context: InvocationContext
) {
  try {
    context.log("Simulando envio para Redmine:", redmineData);

    // Em produção, aqui faria:
    // 1. Autenticação com API do Redmine
    // 2. Criação/atualização do ticket
    // 3. Upload de evidências anexas
    // 4. Registro de tempo trabalhado

    // Simula delay de API externa
    await new Promise((resolve) => setTimeout(resolve, 500));

    return {
      ticketId: `REDMINE-${Date.now()}`,
      status: "submitted",
      url: `https://redmine.example.com/issues/${Date.now()}`,
      submittedAt: new Date().toISOString(),
      timeLogged: redmineData.timeSpent || 0,
    };
  } catch (error) {
    context.error("Erro na simulação do Redmine:", error);
    return {
      error: "Falha ao enviar para Redmine",
      details: error instanceof Error ? error.message : "Erro desconhecido",
    };
  }
}

app.http("manageSuggestion", {
  methods: ["POST", "PUT", "OPTIONS"],
  authLevel: "anonymous",
  route: "manage-suggestion",
  handler: manageSuggestion,
});
