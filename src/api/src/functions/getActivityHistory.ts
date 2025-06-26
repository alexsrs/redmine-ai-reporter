import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { TableClient } from "@azure/data-tables";
import ConfigService from "../config";
import { ActivityHistory } from "../types";

/**
 * Azure Function para recuperar histórico de atividades do usuário
 */
export async function getActivityHistory(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log("Função getActivityHistory iniciada");

  // CORS preflight
  if (request.method === "OPTIONS") {
    return {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    };
  }

  if (request.method !== "GET") {
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

    // Parâmetros de query
    const userId = request.query.get("userId");
    const limit = Math.min(parseInt(request.query.get("limit") || "50"), 100);
    const activityType = request.query.get("activityType");
    const startDate = request.query.get("startDate");
    const endDate = request.query.get("endDate");

    if (!userId) {
      return {
        status: 400,
        headers: { "Access-Control-Allow-Origin": "*" },
        jsonBody: { error: "userId é obrigatório" },
      };
    }

    const tableClient = new TableClient(
      config.storageConnectionString,
      "RedmineAIHistory"
    );

    // Constroi o filtro
    let filter = `PartitionKey eq '${userId}'`;

    if (activityType) {
      filter += ` and activityType eq '${activityType}'`;
    }

    if (startDate) {
      filter += ` and createdAt ge datetime'${startDate}'`;
    }

    if (endDate) {
      filter += ` and createdAt le datetime'${endDate}'`;
    }

    context.log("Consultando histórico com filtro:", filter);

    // Query entities usando método correto
    const entities = tableClient.listEntities({
      queryOptions: {
        filter: filter,
        select: [
          "rowKey",
          "activityType",
          "description",
          "suggestion",
          "confidence",
          "status",
          "createdAt",
          "updatedAt",
          "redmineTicketId",
          "timeSpent",
          "evidenceIds",
        ],
      },
    });

    const activities: ActivityHistory[] = [];
    let count = 0;

    for await (const entity of entities) {
      if (count >= limit) break;

      activities.push({
        id: entity.rowKey as string,
        userId: userId,
        activityType: entity.activityType as string,
        description: entity.description as string,
        suggestion: entity.suggestion as string,
        confidence: entity.confidence as number,
        status: entity.status as string,
        createdAt: entity.createdAt as Date,
        updatedAt: entity.updatedAt as Date,
        redmineTicketId: entity.redmineTicketId as string,
        timeSpent: entity.timeSpent as number,
        evidenceIds: entity.evidenceIds
          ? JSON.parse(entity.evidenceIds as string)
          : [],
      });

      count++;
    }

    // Ordena por data de criação (mais recente primeiro)
    activities.sort(
      (a, b) =>
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    );

    const response = {
      success: true,
      data: activities,
      total: activities.length,
      userId: userId,
      filters: {
        activityType,
        startDate,
        endDate,
        limit,
      },
    };

    context.log(
      `Retornando ${activities.length} atividades para usuário ${userId}`
    );

    return {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
      jsonBody: response,
    };
  } catch (error) {
    context.error("Erro ao buscar histórico:", error);

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

app.http("getActivityHistory", {
  methods: ["GET", "OPTIONS"],
  authLevel: "anonymous",
  route: "activity-history",
  handler: getActivityHistory,
});
