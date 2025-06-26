const { app } = require("@azure/functions");

console.log("🚀 Starting Azure Functions app...");

app.http("health", {
  methods: ["GET"],
  authLevel: "anonymous",
  handler: async (request, context) => {
    console.log("✅ Health endpoint called successfully!");
    context.log("Health check function executed");

    return {
      jsonBody: {
        status: "healthy",
        timestamp: new Date().toISOString(),
        message: "Azure Functions is working!",
      },
    };
  },
});

console.log("✅ Health function registered successfully!");
