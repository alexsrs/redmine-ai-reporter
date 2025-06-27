module.exports = async function (context, req) {
  context.log("Starting generate-suggestion function...");

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
    // Leitura do texto enviado pelo usuário
    let activityText = "";
    if (req.body && typeof req.body === "object") {
      activityText = req.body.texto || req.body.text || "";
    } else if (req.query && req.query.texto) {
      activityText = req.query.texto;
    }

    context.log(`Texto recebido: "${activityText}"`);

    if (!activityText || activityText.trim() === "") {
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

    // Tentar integração com Azure OpenAI
    try {
      const openaiResponse = await callAzureOpenAI(context, activityText);
      if (openaiResponse) {
        context.log("Resposta do Azure OpenAI obtida com sucesso");
        context.res = {
          status: 200,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
          body: openaiResponse,
        };
        return;
      }
    } catch (openaiError) {
      context.log.warn(
        "Erro ao chamar Azure OpenAI, usando fallback:",
        openaiError.message
      );
    }

    // Fallback para mock response
    context.log("Usando resposta mock como fallback");
    const mockResponse = generateMockResponse(activityText);

    context.res = {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: mockResponse,
    };
  } catch (error) {
    context.log.error("Erro na função:", error.message);
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

// Função para chamar Azure OpenAI com retry e timeout
async function callAzureOpenAI(context, activityText) {
  // Configuração do Azure OpenAI a partir de variáveis de ambiente
  const endpoint = process.env.AZURE_OPENAI_ENDPOINT;
  const apiKey = process.env.AZURE_OPENAI_API_KEY;
  const deployment = process.env.AZURE_OPENAI_MODEL_DEPLOYMENT || "gpt-4o-mini";
  const apiVersion = "2024-04-01-preview";

  if (!endpoint || !apiKey) {
    context.log.warn(
      "Azure OpenAI não configurado (endpoint ou API key ausente)"
    );
    return null;
  }

  const url = `${endpoint}openai/deployments/${deployment}/chat/completions?api-version=${apiVersion}`;

  const payload = {
    messages: [
      {
        role: "system",
        content: `Você é um assistente para análise de atividades do Redmine. Responda APENAS com JSON válido seguindo este formato:
{
  "sugestao": {
    "data": "YYYY-MM-DD",
    "usuario": "Usuário AI", 
    "atividade": "Treinamento",
    "tarefa": "Resumo da tarefa",
    "comentario": "Descrição da atividade",
    "horas": "2.0",
    "evidencias": "Análise baseada em descrição textual"
  },
  "confianca": 0.85,
  "timestamp": "ISO DateTime",
  "id": "suggestion_XXXXX"
}`,
      },
      {
        role: "user",
        content: `Analise: "${activityText}"`,
      },
    ],
    max_tokens: 500,
    temperature: 0.3,
  };

  // Implementação de retry com exponential backoff
  const maxRetries = 3;
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      context.log(`Tentativa ${attempt}/${maxRetries} para Azure OpenAI`);

      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "api-key": apiKey,
        },
        body: JSON.stringify(payload),
        signal: AbortSignal.timeout(30000), // 30 segundos timeout
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();

      if (data.choices && data.choices.length > 0) {
        const aiContent = data.choices[0].message.content;
        try {
          const aiResponse = JSON.parse(aiContent);
          aiResponse.source = "azure_openai";
          aiResponse.ai_used = true;
          return aiResponse;
        } catch (parseError) {
          throw new Error(
            `Erro ao parsear resposta da IA: ${parseError.message}`
          );
        }
      } else {
        throw new Error("Resposta inválida do Azure OpenAI");
      }
    } catch (error) {
      context.log.warn(`Tentativa ${attempt} falhou:`, error.message);

      if (attempt === maxRetries) {
        throw error;
      }

      // Exponential backoff: 1s, 2s, 4s
      const delay = Math.pow(2, attempt - 1) * 1000;
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }
}

// Função para gerar resposta mock
function generateMockResponse(activityText) {
  const now = new Date();
  const today = now.toISOString().split("T")[0];
  const simpleId = `suggestion_${Date.now()}_${Math.floor(
    Math.random() * 1000
  )}`;

  return {
    sugestao: {
      data: today,
      usuario: "Usuário AI",
      atividade: "Treinamento",
      tarefa: activityText
        ? activityText.substring(0, 50)
        : "Resumo da tarefa mock",
      comentario: activityText
        ? `Atividade analisada: ${activityText}`
        : "Descrição da atividade mock",
      horas: "2.0",
      evidencias: "Análise baseada em descrição textual (mock)",
    },
    confianca: 0.85,
    timestamp: now.toISOString(),
    id: simpleId,
    source: "mock",
  };
}
