import React, { useState, useEffect } from "react";
import { ActivityHistory } from "../types";
import { apiService } from "../services/api";
import { toast } from "react-hot-toast";

interface HistoryViewProps {
  userId: string;
}

export const HistoryView: React.FC<HistoryViewProps> = ({ userId }) => {
  const [history, setHistory] = useState<ActivityHistory[]>([]);
  const [loading, setLoading] = useState(false);
  const [filter, setFilter] = useState({
    activityType: "",
    startDate: "",
    endDate: "",
    status: "",
  });

  useEffect(() => {
    loadHistory();
  }, [userId, filter]);

  const loadHistory = async () => {
    if (!userId) return;

    setLoading(true);
    try {
      const data = await apiService.getActivityHistory(userId, filter);
      setHistory(data.data || []);
    } catch (error) {
      console.error("Erro ao carregar histórico:", error);
      toast.error("Erro ao carregar histórico de atividades");
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (activityId: string) => {
    try {
      await apiService.manageSuggestion(activityId, userId, "approve");
      toast.success("Sugestão aprovada com sucesso!");
      loadHistory(); // Recarrega o histórico
    } catch (error) {
      toast.error("Erro ao aprovar sugestão");
    }
  };

  const handleReject = async (activityId: string, feedback?: string) => {
    try {
      await apiService.manageSuggestion(activityId, userId, "reject", feedback);
      toast.success("Sugestão rejeitada");
      loadHistory();
    } catch (error) {
      toast.error("Erro ao rejeitar sugestão");
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "approved":
        return "text-green-600 bg-green-100";
      case "rejected":
        return "text-red-600 bg-red-100";
      case "pending":
        return "text-yellow-600 bg-yellow-100";
      case "modified":
        return "text-blue-600 bg-blue-100";
      default:
        return "text-gray-600 bg-gray-100";
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case "approved":
        return "Aprovada";
      case "rejected":
        return "Rejeitada";
      case "pending":
        return "Pendente";
      case "modified":
        return "Modificada";
      default:
        return status;
    }
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">
          Histórico de Atividades
        </h2>

        {/* Filtros */}
        <div className="bg-white p-4 rounded-lg shadow-sm border mb-6">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo de Atividade
              </label>
              <select
                value={filter.activityType}
                onChange={(e) =>
                  setFilter({ ...filter, activityType: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Todos</option>
                <option value="development">Desenvolvimento</option>
                <option value="testing">Testes</option>
                <option value="meeting">Reunião</option>
                <option value="documentation">Documentação</option>
                <option value="support">Suporte</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Data Início
              </label>
              <input
                type="date"
                value={filter.startDate}
                onChange={(e) =>
                  setFilter({ ...filter, startDate: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Data Fim
              </label>
              <input
                type="date"
                value={filter.endDate}
                onChange={(e) =>
                  setFilter({ ...filter, endDate: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Status
              </label>
              <select
                value={filter.status}
                onChange={(e) =>
                  setFilter({ ...filter, status: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Todos</option>
                <option value="pending">Pendente</option>
                <option value="approved">Aprovada</option>
                <option value="rejected">Rejeitada</option>
                <option value="modified">Modificada</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {/* Lista de Atividades */}
      {loading ? (
        <div className="flex justify-center py-8">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      ) : (
        <div className="space-y-4">
          {history.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <p>Nenhuma atividade encontrada</p>
            </div>
          ) : (
            history.map((activity) => (
              <div
                key={activity.id}
                className="bg-white rounded-lg shadow-sm border p-6"
              >
                <div className="flex justify-between items-start mb-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <span
                        className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(
                          activity.status
                        )}`}
                      >
                        {getStatusText(activity.status)}
                      </span>
                      <span className="text-sm text-gray-500">
                        {activity.activityType}
                      </span>
                      <span className="text-sm text-gray-400">
                        {new Date(activity.createdAt).toLocaleDateString(
                          "pt-BR"
                        )}
                      </span>
                    </div>

                    <h3 className="text-lg font-medium text-gray-900 mb-2">
                      {activity.description}
                    </h3>

                    {activity.suggestion && (
                      <div className="bg-gray-50 p-3 rounded-md mb-3">
                        <h4 className="text-sm font-medium text-gray-700 mb-1">
                          Sugestão Gerada:
                        </h4>
                        <div className="text-sm text-gray-600">
                          {typeof activity.suggestion === "string"
                            ? activity.suggestion
                            : JSON.stringify(activity.suggestion, null, 2)}
                        </div>
                      </div>
                    )}

                    <div className="flex items-center gap-4 text-sm text-gray-500">
                      {activity.confidence && (
                        <span>
                          Confiança: {Math.round(activity.confidence * 100)}%
                        </span>
                      )}
                      {activity.timeSpent && (
                        <span>Tempo: {activity.timeSpent}h</span>
                      )}
                      {activity.redmineTicketId && (
                        <span>Ticket: {activity.redmineTicketId}</span>
                      )}
                    </div>
                  </div>

                  {activity.status === "pending" && (
                    <div className="flex gap-2 ml-4">
                      <button
                        onClick={() => handleApprove(activity.id)}
                        className="px-3 py-1 bg-green-600 text-white text-sm rounded-md hover:bg-green-700 transition-colors"
                      >
                        Aprovar
                      </button>
                      <button
                        onClick={() => handleReject(activity.id)}
                        className="px-3 py-1 bg-red-600 text-white text-sm rounded-md hover:bg-red-700 transition-colors"
                      >
                        Rejeitar
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
};
