import { useState, useEffect } from "react";
import { Toaster, toast } from "react-hot-toast";
import { ActivityForm } from "./components/ActivityForm";
import { SuggestionCard } from "./components/SuggestionCard";
import { HistoryView } from "./components/HistoryView";
import { EvidenceUploader } from "./components/EvidenceUploader";
import { aiService } from "./services/api";
import { RedmineEntry, ActivityInput, SuggestionResponse } from "./types";
import "./index.css";

function App() {
  // State management
  const [loading, setLoading] = useState(false);
  const [suggestion, setSuggestion] = useState<SuggestionResponse | null>(null);
  const [editedSuggestion, setEditedSuggestion] = useState<RedmineEntry | null>(
    null
  );
  const [activeTab, setActiveTab] = useState<"generate" | "history">(
    "generate"
  );
  const [userId] = useState("demo-user-" + Date.now()); // Em produção seria obtido da autenticação

  // Atualiza a sugestão editada quando uma nova sugestão é gerada
  useEffect(() => {
    if (suggestion) {
      setEditedSuggestion(suggestion.sugestao);
    }
  }, [suggestion]);

  const handleGenerate = async (input: ActivityInput) => {
    try {
      setLoading(true);
      setSuggestion(null);
      setEditedSuggestion(null);

      const response = await aiService.generateSuggestion(input);
      setSuggestion(response);

      toast.success("Sugestão gerada com sucesso!");
    } catch (error) {
      console.error("Erro ao gerar sugestão:", error);
      toast.error(
        "Erro ao gerar sugestão. Verifique sua conexão e tente novamente."
      );
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async () => {
    if (!suggestion) return;

    try {
      setLoading(true);
      await aiService.approveSuggestion(suggestion.id);
      toast.success("Sugestão aprovada e salva com sucesso!");

      // Limpa o formulário após aprovar
      setSuggestion(null);
      setEditedSuggestion(null);
    } catch (error) {
      console.error("Erro ao aprovar sugestão:", error);
      toast.error("Erro ao aprovar sugestão. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (entry: RedmineEntry) => {
    setEditedSuggestion(entry);
  };

  const handleTabChange = (tab: "generate" | "history") => {
    setActiveTab(tab);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Toaster
        position="top-right"
        toastOptions={{
          duration: 4000,
          style: {
            background: "#363636",
            color: "#fff",
          },
        }}
      />

      <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="px-4 py-6 sm:px-0">
          <div className="text-center">
            <h1 className="text-3xl font-bold text-gray-900">
              Redmine AI Reporter
            </h1>
            <p className="mt-2 text-lg text-gray-600">
              IA para análise de atividades e preenchimento automático no
              Redmine
            </p>
            <p className="mt-1 text-sm text-gray-500">
              Desenvolvido por Alex Sandro Ribeiro de Souza - SEAP-RJ
            </p>
          </div>
        </div>

        {/* Main Content */}
        <div className="px-4 py-6 sm:px-0">
          <div className="space-y-6">
            {/* Tab Navigation */}
            <div className="flex space-x-4">
              <button
                onClick={() => handleTabChange("generate")}
                className={`flex-1 px-4 py-2 font-medium text-sm rounded-lg focus:outline-none ${
                  activeTab === "generate"
                    ? "bg-blue-600 text-white"
                    : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                }`}
              >
                Gerar Sugestão
              </button>
              <button
                onClick={() => handleTabChange("history")}
                className={`flex-1 px-4 py-2 font-medium text-sm rounded-lg focus:outline-none ${
                  activeTab === "history"
                    ? "bg-blue-600 text-white"
                    : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                }`}
              >
                Histórico de Sugestões
              </button>
            </div>

            {/* Formulário de entrada */}
            {activeTab === "generate" && (
              <ActivityForm
                onGenerate={handleGenerate}
                loading={loading}
                suggestion={editedSuggestion}
              />
            )}

            {/* Sugestão gerada */}
            {suggestion && editedSuggestion && activeTab === "generate" && (
              <SuggestionCard
                suggestion={editedSuggestion}
                confidence={suggestion.confianca}
                onApprove={handleApprove}
                onEdit={handleEdit}
                loading={loading}
              />
            )}

            {/* Histórico de sugestões */}
            {activeTab === "history" && <HistoryView userId={userId} />}

            {/* Upload de evidências */}
            {activeTab === "history" && <EvidenceUploader userId={userId} />}
          </div>
        </div>

        {/* Footer */}
        <footer className="mt-12 text-center text-sm text-gray-500">
          <p>
            Redmine AI Reporter v1.0.0 | Secretaria de Estado de Administração
            Penitenciária - RJ
          </p>
          <p className="mt-1">
            Projeto Portfolio - Azure AI Foundry + Static Web Apps + Functions
          </p>
        </footer>
      </div>
    </div>
  );
}

export default App;
