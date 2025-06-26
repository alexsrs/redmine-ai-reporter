import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";

export async function health(
  _request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log("Health check executado");

  try {
    const status = {
      status: "healthy",
      timestamp: new Date().toISOString(),
      version: "1.0.0",
      service: "redmine-ai-reporter-api",
      environment: process.env.NODE_ENV || "development",
    };

    return {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
      },
      jsonBody: status,
    };
  } catch (error) {
    context.error("Erro no health check:", error);

    return {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      jsonBody: {
        status: "unhealthy",
        timestamp: new Date().toISOString(),
        error: "Internal server error",
      },
    };
  }
}

// Registrar a função
app.http("health", {
  methods: ["GET", "OPTIONS"],
  route: "health",
  authLevel: "anonymous",
  handler: health,
});
