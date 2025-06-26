const { app } = require("@azure/functions");

// Função de Health Check simples
app.http("health", {
  methods: ["GET", "OPTIONS"],
  authLevel: "anonymous",
  route: "health",
  handler: async (request, context) => {
    context.log("Health check endpoint called");

    return {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
      },
      jsonBody: {
        status: "healthy",
        timestamp: new Date().toISOString(),
        version: "1.0.0",
        service: "redmine-ai-reporter-api",
      },
    };
  },
});

console.log("Functions registered successfully");
