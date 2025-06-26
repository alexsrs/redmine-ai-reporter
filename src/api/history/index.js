module.exports = async function (context, req) {
  context.log("Retrieving suggestions history...");

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

  try {
    // TODO: Implement actual history retrieval from Azure Table Storage
    // For now, return mock data
    const mockHistory = [
      {
        id: "hist_001",
        input: "Desenvolvimento de nova funcionalidade no sistema",
        suggestion: {
          data: "2025-06-26",
          usuario: "Usuario Teste",
          atividade: "Desenvolvimento",
          tarefa: "Nova funcionalidade",
          comentario:
            "Implementação de nova funcionalidade no sistema principal",
          horas: "4.0",
          evidencias: "Screenshots da funcionalidade",
        },
        approved: true,
        createdAt: new Date(Date.now() - 86400000).toISOString(), // 1 day ago
        updatedAt: new Date(Date.now() - 82800000).toISOString(), // 23 hours ago
      },
      {
        id: "hist_002",
        input: "Correção de bug no módulo de relatórios",
        suggestion: {
          data: "2025-06-25",
          usuario: "Usuario Teste",
          atividade: "Correção",
          tarefa: "Bug fix - relatórios",
          comentario: "Corrigido problema de exibição nos relatórios mensais",
          horas: "1.5",
          evidencias: "Print do erro e solução aplicada",
        },
        approved: false,
        createdAt: new Date(Date.now() - 172800000).toISOString(), // 2 days ago
        updatedAt: new Date(Date.now() - 172800000).toISOString(),
      },
      {
        id: "hist_003",
        input: "Reunião de alinhamento do projeto",
        suggestion: {
          data: "2025-06-24",
          usuario: "Usuario Teste",
          atividade: "Reunião",
          tarefa: "Alinhamento do projeto",
          comentario:
            "Participação em reunião para definição de próximos passos",
          horas: "2.0",
          evidencias: "Ata da reunião",
        },
        approved: true,
        createdAt: new Date(Date.now() - 259200000).toISOString(), // 3 days ago
        updatedAt: new Date(Date.now() - 259200000).toISOString(),
      },
    ];

    context.res = {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: mockHistory,
    };
  } catch (error) {
    context.log.error("Error retrieving history:", error);
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
