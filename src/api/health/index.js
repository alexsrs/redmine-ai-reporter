module.exports = async function (context, req) {
  context.log("Health check function processed a request.");

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    context.res = {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    };
    return;
  }

  // Set CORS headers
  context.res = {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    },
    body: {
      status: "healthy",
      timestamp: new Date().toISOString(),
      version: "1.0.0",
      service: "redmine-ai-reporter-api",
    },
  };
};
