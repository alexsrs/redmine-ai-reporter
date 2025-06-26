import React, { useState } from "react";
import { apiService } from "../services/api";
import { toast } from "react-hot-toast";

interface EvidenceUploaderProps {
  userId: string;
  activityType?: string;
  onUploadComplete?: (evidenceId: string, url: string) => void;
}

export const EvidenceUploader: React.FC<EvidenceUploaderProps> = ({
  userId,
  activityType,
  onUploadComplete,
}) => {
  const [uploading, setUploading] = useState(false);
  const [dragActive, setDragActive] = useState(false);
  const [description, setDescription] = useState("");

  const handleFile = async (file: File) => {
    if (!file) return;

    // Validações
    const maxSize = 5 * 1024 * 1024; // 5MB
    const allowedTypes = [
      "image/png",
      "image/jpeg",
      "image/gif",
      "application/pdf",
      "text/plain",
    ];

    if (file.size > maxSize) {
      toast.error("Arquivo muito grande (máximo 5MB)");
      return;
    }

    if (!allowedTypes.includes(file.type)) {
      toast.error("Tipo de arquivo não suportado");
      return;
    }

    setUploading(true);

    try {
      // Converte o arquivo para base64
      const fileContent = await fileToBase64(file);

      const result = await apiService.uploadEvidence(
        userId,
        file.name,
        fileContent,
        file.type,
        activityType,
        description
      );

      toast.success("Evidência enviada com sucesso!");
      setDescription("");

      if (onUploadComplete) {
        onUploadComplete(result.evidenceId, result.url);
      }
    } catch (error) {
      console.error("Erro no upload:", error);
      toast.error("Erro ao enviar evidência");
    } finally {
      setUploading(false);
    }
  };

  const fileToBase64 = (file: File): Promise<string> => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const result = reader.result as string;
        // Remove o prefixo "data:tipo;base64," para obter apenas o base64
        const base64 = result.split(",")[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      handleFile(file);
    }
  };

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);

    const file = e.dataTransfer.files?.[0];
    if (file) {
      handleFile(file);
    }
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-sm border">
      <h3 className="text-lg font-medium text-gray-900 mb-4">
        Anexar Evidências
      </h3>

      {/* Campo de descrição */}
      <div className="mb-4">
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Descrição (opcional)
        </label>
        <input
          type="text"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Descreva a evidência..."
          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      {/* Área de upload */}
      <div
        className={`relative border-2 border-dashed rounded-lg p-6 text-center transition-colors ${
          dragActive
            ? "border-blue-500 bg-blue-50"
            : "border-gray-300 hover:border-gray-400"
        }`}
        onDragEnter={handleDrag}
        onDragLeave={handleDrag}
        onDragOver={handleDrag}
        onDrop={handleDrop}
      >
        {uploading ? (
          <div className="flex flex-col items-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mb-2"></div>
            <p className="text-sm text-gray-600">Enviando evidência...</p>
          </div>
        ) : (
          <>
            <input
              type="file"
              accept="image/*,.pdf,.txt"
              onChange={handleFileSelect}
              className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
            />

            <div className="flex flex-col items-center">
              <svg
                className="w-12 h-12 text-gray-400 mb-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
                />
              </svg>

              <p className="text-lg font-medium text-gray-900 mb-1">
                Arraste arquivos aqui ou clique para selecionar
              </p>

              <p className="text-sm text-gray-500 mb-2">
                Suporte: PNG, JPG, GIF, PDF, TXT (máx. 5MB)
              </p>

              <button
                type="button"
                className="mt-2 px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 transition-colors"
              >
                Selecionar Arquivo
              </button>
            </div>
          </>
        )}
      </div>

      {/* Dicas */}
      <div className="mt-4 text-xs text-gray-500">
        <p>
          💡 <strong>Dicas:</strong>
        </p>
        <ul className="list-disc list-inside mt-1 space-y-1">
          <li>Screenshots de telas do sistema</li>
          <li>Documentos PDF relevantes</li>
          <li>Logs de erro em arquivo .txt</li>
          <li>Imagens de diagramas ou fluxos</li>
        </ul>
      </div>
    </div>
  );
};
