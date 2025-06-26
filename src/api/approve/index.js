module.exports = async function (context, req) {
  context.log("Approving suggestion...");

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    context.res = {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    };
    return;
  }

  try {
    const suggestionId = req.params.id;

    if (!suggestionId) {
      context.res = {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: {
          error: "ID da sugestão é obrigatório",
        },
      };
      return;
    }

    const sendToRedmine = (req.body && req.body.sendToRedmine) || false;

    context.log(
      `Approving suggestion ${suggestionId}, sendToRedmine: ${sendToRedmine}`
    );

    // TODO: Implement actual approval logic
    let response = {
      success: true,
      suggestionId: suggestionId,
      approved: true,
      timestamp: new Date().toISOString(),
    };

    if (sendToRedmine) {
      response.redmineTicketId = `TICKET_${Date.now()}`;
      response.redmineStatus = "created";
      context.log(`Mock: Created Redmine ticket ${response.redmineTicketId}`);
    }

    context.res = {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: response,
    };
  } catch (error) {
    context.log.error("Error approving suggestion:", error);
    context.res = {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: {
        error: "Erro interno do servidor",
        details: error.message,
      },
    };
  }
};
