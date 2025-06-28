module.exports = async function (context, req) {
  context.log("Debug config endpoint called");

  const endpoint = process.env.AZURE_OPENAI_ENDPOINT;
  const apiKey = process.env.AZURE_OPENAI_API_KEY;
  const deployment = process.env.AZURE_OPENAI_MODEL_DEPLOYMENT;

  context.res = {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
    body: {
      endpoint: endpoint || "NOT_SET",
      apiKey: apiKey ? `${apiKey.substring(0, 20)}...` : "NOT_SET",
      deployment: deployment || "NOT_SET",
      hasEndpoint: !!endpoint,
      hasApiKey: !!apiKey,
      hasDeployment: !!deployment,
      keyVaultReference: apiKey && apiKey.startsWith("@Microsoft.KeyVault"),
    },
  };
};
