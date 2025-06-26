import React, { useState, useCallback } from "react";
import { ActivityInput, RedmineEntry } from "../types";
import { DocumentArrowUpIcon, SparklesIcon } from "@heroicons/react/24/outline";

interface Props {
  onGenerate: (input: ActivityInput) => Promise<void>;
  loading: boolean;
  suggestion: RedmineEntry | null;
}

export const ActivityForm: React.FC<Props> = ({ onGenerate, loading }) => {
  const [texto, setTexto] = useState("");
  const [arquivos, setArquivos] = useState<File[]>([]);

  const handleSubmit = useCallback(
    async (e: React.FormEvent) => {
      e.preventDefault();
      if (!texto.trim()) return;

      await onGenerate({
        texto: texto.trim(),
        arquivos: arquivos.length > 0 ? arquivos : undefined,
      });
    },
    [texto, arquivos, onGenerate]
  );

  const handleFileChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const files = Array.from(e.target.files || []);
      setArquivos(files);
    },
    []
  );

  const removeFile = useCallback((index: number) => {
    setArquivos((prev) => prev.filter((_, i) => i !== index));
  }, []);

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
        <SparklesIcon className="h-5 w-5 mr-2 text-primary-500" />
        Descreva sua Atividade
      </h2>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label
            htmlFor="atividade"
            className="block text-sm font-medium text-gray-700 mb-2"
          >
            Descrição da Atividade
          </label>
          <textarea
            id="atividade"
            value={texto}
            onChange={(e) => setTexto(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            rows={6}
            placeholder="Ex: Participei de uma reunião com o pessoal da LGPD para fazer um gap analysis. A reunião durou 3 horas e foi feita no Teams. O objetivo era analisar a conformidade dos dados da SEAP com a LGPD."
            required
          />
          <p className="mt-1 text-sm text-gray-500">
            Descreva sua atividade em linguagem natural. Inclua duração,
            ferramentas utilizadas e objetivos.
          </p>
        </div>

        <div>
          <label
            htmlFor="evidencias"
            className="block text-sm font-medium text-gray-700 mb-2"
          >
            Evidências (Opcional)
          </label>
          <div className="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md">
            <div className="space-y-1 text-center">
              <DocumentArrowUpIcon className="mx-auto h-12 w-12 text-gray-400" />
              <div className="flex text-sm text-gray-600">
                <label
                  htmlFor="file-upload"
                  className="relative cursor-pointer bg-white rounded-md font-medium text-primary-600 hover:text-primary-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-primary-500"
                >
                  <span>Carregar arquivos</span>
                  <input
                    id="file-upload"
                    name="file-upload"
                    type="file"
                    className="sr-only"
                    multiple
                    accept=".png,.jpg,.jpeg,.pdf,.txt,.docx"
                    onChange={handleFileChange}
                  />
                </label>
                <p className="pl-1">ou arraste e solte</p>
              </div>
              <p className="text-xs text-gray-500">
                PNG, JPG, PDF, TXT, DOCX até 10MB cada
              </p>
            </div>
          </div>
        </div>

        {arquivos.length > 0 && (
          <div className="space-y-2">
            <h4 className="text-sm font-medium text-gray-700">
              Arquivos Selecionados:
            </h4>
            {arquivos.map((arquivo, index) => (
              <div
                key={index}
                className="flex items-center justify-between bg-gray-50 p-2 rounded"
              >
                <span className="text-sm text-gray-600">{arquivo.name}</span>
                <button
                  type="button"
                  onClick={() => removeFile(index)}
                  className="text-red-500 hover:text-red-700 text-sm"
                >
                  Remover
                </button>
              </div>
            ))}
          </div>
        )}

        <button
          type="submit"
          disabled={loading || !texto.trim()}
          className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? (
            <>
              <svg
                className="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle
                  className="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  strokeWidth="4"
                ></circle>
                <path
                  className="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                ></path>
              </svg>
              Gerando Sugestão...
            </>
          ) : (
            <>
              <SparklesIcon className="h-5 w-5 mr-2" />
              Gerar Sugestão de Relatório
            </>
          )}
        </button>
      </form>
    </div>
  );
};
