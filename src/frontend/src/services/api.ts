import axios from "axios";
import {
  ActivityInput,
  SuggestionResponse,
  HistoryEntry,
  ActivityHistory,
} from "../types";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "/api";

export const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    "Content-Type": "application/json",
  },
});

// Interceptor para tratamento de erros
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error("API Error:", error);
    return Promise.reject(error);
  }
);

export const aiService = {
  /**
   * Gera sugestão de relatório baseada na atividade descrita
   */
  async generateSuggestion(input: ActivityInput): Promise<SuggestionResponse> {
    console.log("Enviando para API:", { texto: input.texto });
    console.log("URL da API:", API_BASE_URL);

    // For now, send as JSON. File upload can be implemented later
    const requestData = {
      texto: input.texto,
      // Note: File upload will be implemented in a separate endpoint
      arquivos: input.arquivos ? input.arquivos.map((f) => f.name) : [],
    };

    const response = await api.post<SuggestionResponse>(
      "/generate-suggestion",
      requestData
    );

    return response.data;
  },

  /**
   * Recupera histórico de sugestões
   */
  async getHistory(): Promise<HistoryEntry[]> {
    const response = await api.get<HistoryEntry[]>("/history");
    return response.data;
  },

  /**
   * Aprova uma sugestão e opcionalmente envia para o Redmine
   */
  async approveSuggestion(
    id: string,
    sendToRedmine: boolean = false
  ): Promise<void> {
    await api.post(`/approve/${id}`, { sendToRedmine });
  },

  /**
   * Testa a conexão com a API
   */
  async healthCheck(): Promise<{ status: string; timestamp: string }> {
    const response = await api.get("/health");
    return response.data;
  },

  /**
   * Recupera histórico de atividades com filtros
   */
  async getActivityHistory(
    userId: string,
    filters?: any
  ): Promise<{ data: ActivityHistory[]; total: number }> {
    const params = new URLSearchParams({ userId });

    if (filters) {
      Object.keys(filters).forEach((key) => {
        if (filters[key]) {
          params.append(key, filters[key]);
        }
      });
    }

    const response = await api.get(`/activity-history?${params.toString()}`);
    return response.data;
  },

  /**
   * Gerencia sugestão (aprovar, rejeitar, modificar)
   */
  async manageSuggestion(
    activityId: string,
    userId: string,
    action: string,
    feedback?: string,
    redmineData?: any
  ): Promise<any> {
    const response = await api.post("/manage-suggestion", {
      activityId,
      userId,
      action,
      feedback,
      redmineData,
    });
    return response.data;
  },

  /**
   * Upload de evidência (arquivo)
   */
  async uploadEvidence(
    userId: string,
    fileName: string,
    fileContent: string,
    fileType: string,
    activityType?: string,
    description?: string
  ): Promise<any> {
    const response = await api.post("/upload-evidence", {
      userId,
      fileName,
      fileContent,
      fileType,
      activityType,
      description,
    });
    return response.data;
  },
};

export const apiService = aiService;
