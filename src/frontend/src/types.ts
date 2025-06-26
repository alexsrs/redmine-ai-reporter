export interface RedmineEntry {
  data: string;
  usuario: string;
  atividade: string;
  tarefa: string;
  comentario: string;
  horas: string;
  evidencias: string;
}

export interface ActivityInput {
  texto: string;
  arquivos?: File[];
}

export interface SuggestionResponse {
  sugestao: RedmineEntry;
  confianca: number;
  timestamp: string;
  id: string;
}

export interface HistoryEntry {
  id: string;
  input: string;
  suggestion: RedmineEntry;
  approved: boolean;
  createdAt: string;
  updatedAt?: string;
}

export interface ActivityHistory {
  id: string;
  userId: string;
  activityType: string;
  description: string;
  suggestion: string;
  confidence: number;
  status: string;
  createdAt: Date;
  updatedAt: Date;
  redmineTicketId?: string;
  timeSpent?: number;
  evidenceIds: string[];
}
