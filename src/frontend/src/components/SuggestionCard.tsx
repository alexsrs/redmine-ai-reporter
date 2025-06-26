import React from "react";
import { RedmineEntry } from "../types";
import {
  CheckIcon,
  ClockIcon,
  DocumentTextIcon,
} from "@heroicons/react/24/outline";

interface Props {
  suggestion: RedmineEntry;
  confidence: number;
  onApprove: () => void;
  onEdit: (entry: RedmineEntry) => void;
  loading?: boolean;
}

export const SuggestionCard: React.FC<Props> = ({
  suggestion,
  confidence,
  onApprove,
  onEdit,
  loading = false,
}) => {
  const confidenceColor =
    confidence >= 80
      ? "text-green-600"
      : confidence >= 60
      ? "text-yellow-600"
      : "text-red-600";
  const confidenceBg =
    confidence >= 80
      ? "bg-green-100"
      : confidence >= 60
      ? "bg-yellow-100"
      : "bg-red-100";

  return (
    <div className="bg-white rounded-lg shadow-md p-6 border-l-4 border-primary-500">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900 flex items-center">
          <DocumentTextIcon className="h-5 w-5 mr-2 text-primary-500" />
          Sugestão de Relatório
        </h3>
        <div
          className={`px-3 py-1 rounded-full text-sm font-medium ${confidenceBg} ${confidenceColor}`}
        >
          {confidence}% confiança
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Data
          </label>
          <input
            type="text"
            value={suggestion.data}
            onChange={(e) => onEdit({ ...suggestion, data: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Usuário
          </label>
          <input
            type="text"
            value={suggestion.usuario}
            onChange={(e) => onEdit({ ...suggestion, usuario: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Atividade
          </label>
          <input
            type="text"
            value={suggestion.atividade}
            onChange={(e) =>
              onEdit({ ...suggestion, atividade: e.target.value })
            }
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Horas
          </label>
          <input
            type="text"
            value={suggestion.horas}
            onChange={(e) => onEdit({ ...suggestion, horas: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div className="md:col-span-2">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Tarefa
          </label>
          <input
            type="text"
            value={suggestion.tarefa}
            onChange={(e) => onEdit({ ...suggestion, tarefa: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div className="md:col-span-2">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Comentário
          </label>
          <textarea
            value={suggestion.comentario}
            onChange={(e) =>
              onEdit({ ...suggestion, comentario: e.target.value })
            }
            rows={3}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div className="md:col-span-2">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Evidências
          </label>
          <input
            type="text"
            value={suggestion.evidencias}
            onChange={(e) =>
              onEdit({ ...suggestion, evidencias: e.target.value })
            }
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>
      </div>

      <div className="flex justify-end space-x-3">
        <button
          onClick={onApprove}
          disabled={loading}
          className="flex items-center px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? (
            <>
              <ClockIcon className="h-4 w-4 mr-2" />
              Processando...
            </>
          ) : (
            <>
              <CheckIcon className="h-4 w-4 mr-2" />
              Aprovar e Salvar
            </>
          )}
        </button>
      </div>
    </div>
  );
};
