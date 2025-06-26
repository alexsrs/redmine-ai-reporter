import { useState, useEffect } from "react";
import { Toaster, toast } from "react-hot-toast";
import { ActivityForm } from "./components/ActivityForm";
import { SuggestionCard } from "./components/SuggestionCard";
import { HistoryView } from "./components/HistoryView";
import { EvidenceUploader } from "./components/EvidenceUploader";
import { aiService } from "./services/api";
import { RedmineEntry, ActivityInput, SuggestionResponse } from "./types";
import aiLogo from "./pngegg.png"; // Importando a imagem
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
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
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

      {/* Floating Background Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-10 left-10 w-24 h-24 bg-blue-200 rounded-full opacity-20 animate-pulse"></div>
        <div className="absolute top-32 right-20 w-16 h-16 bg-purple-200 rounded-full opacity-30 float-animation"></div>
        <div className="absolute bottom-20 left-1/4 w-20 h-20 bg-indigo-200 rounded-full opacity-25 animate-bounce"></div>
      </div>

      <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8 relative z-10">
        {/* Header */}
        <div className="px-4 py-6 sm:px-0 fade-in-up">
          <div className="text-center">
            {/* Logo e Imagem */}
            <div className="flex justify-center items-center mb-4">
              <div className="relative">
                <div className="absolute inset-0 bg-gradient-to-r from-blue-400 to-purple-500 rounded-full blur-xl opacity-30 animate-pulse"></div>
                <img
                  src={aiLogo}
                  alt="Redmine AI Reporter Logo"
                  className="relative w-24 h-24 object-contain mx-auto drop-shadow-2xl float-animation hover:scale-110 transition-transform duration-300 cursor-pointer"
                />
                <div className="absolute -top-2 -right-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white text-xs px-2 py-1 rounded-full font-bold shadow-lg animate-pulse">
                  AI
                </div>
              </div>
            </div>

            <h1 className="text-3xl font-bold text-gray-900 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              Redmine AI Reporter - Patrick
            </h1>
            <p className="mt-2 text-lg text-gray-600">
              🤖 IA para análise de atividades e preenchimento automático no
              Redmine
            </p>
            <p className="mt-1 text-sm text-gray-500">
              ⚡ Desenvolvido por @alexsrs | 🚀 Powered by Azure AI
            </p>

            {/* Badge de Status */}
            <div className="mt-3 flex justify-center">
              <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                <span className="w-2 h-2 bg-green-400 rounded-full mr-2 animate-pulse"></span>
                Sistema Online
              </span>
            </div>
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
          <p>Redmine AI Reporter v1.0.0 | @alexsrs</p>
          <p className="mt-1">
            #Azure AI Foundry #Static Web Apps #Azure Functions
          </p>
        </footer>
      </div>
    </div>
  );
}

export default App;
