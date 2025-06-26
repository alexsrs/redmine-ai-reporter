module.exports = async function (context, req) {
  context.log("Health check function executed");

  const responseMessage = {
    status: "healthy",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
    service: "redmine-ai-reporter-api",
  };

  context.res = {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
    body: responseMessage,
  };
};
