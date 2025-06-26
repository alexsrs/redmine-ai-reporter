module.exports = async function (context, req) {
  context.log("Generating suggestion for activity...");

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    context.res = {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    };
    return;
  }

  try {
    let activityText = "";
    let files = [];

    // Handle JSON request
    if (req.body && req.body.texto) {
      activityText = req.body.texto;
    }

    if (!activityText) {
      context.res = {
        status: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: {
          error: "Texto da atividade é obrigatório",
        },
      };
      return;
    }

    // TODO: Integrate with Azure OpenAI to generate suggestion
    // For now, return a mock response
    const mockSuggestion = {
      sugestao: {
        data: new Date().toISOString().split("T")[0],
        usuario: "Usuario Teste",
        atividade: "Desenvolvimento",
        tarefa:
          activityText.length > 50
            ? activityText.substring(0, 50) + "..."
            : activityText,
        comentario: `Atividade processada: ${activityText}`,
        horas: "2.0",
        evidencias:
          files.length > 0
            ? `${files.length} arquivo(s) anexado(s)`
            : "Sem evidências",
      },
      confianca: 0.85,
      timestamp: new Date().toISOString(),
      id: `suggestion_${Date.now()}`,
    };

    context.res = {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: mockSuggestion,
    };
  } catch (error) {
    context.log.error("Error generating suggestion:", error);
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
