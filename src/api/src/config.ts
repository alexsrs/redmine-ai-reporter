import { DefaultAzureCredential } from "@azure/identity";
import { SecretClient } from "@azure/keyvault-secrets";
import { TableClient } from "@azure/data-tables";
import { BlobServiceClient } from "@azure/storage-blob";
import { AzureConfig } from "./types";

class ConfigService {
  private static instance: ConfigService;
  private config: AzureConfig | null = null;
  private credential = new DefaultAzureCredential();

  private constructor() {}

  public static getInstance(): ConfigService {
    if (!ConfigService.instance) {
      ConfigService.instance = new ConfigService();
    }
    return ConfigService.instance;
  }

  public async getConfig(): Promise<AzureConfig> {
    if (this.config) {
      return this.config;
    }

    try {
      // Usar variáveis de ambiente no Azure Functions
      const keyVaultUri = process.env.KEY_VAULT_URI;

      if (!keyVaultUri) {
        throw new Error("KEY_VAULT_URI environment variable is required");
      }

      const secretClient = new SecretClient(keyVaultUri, this.credential);

      // Buscar secrets do Key Vault
      const [
        openAiEndpointSecret,
        openAiApiKeySecret,
        storageConnectionStringSecret,
      ] = await Promise.all([
        secretClient.getSecret("AZURE-OPENAI-ENDPOINT").catch(() => null),
        secretClient.getSecret("AZURE-OPENAI-API-KEY").catch(() => null),
        secretClient
          .getSecret("AZURE-STORAGE-CONNECTION-STRING")
          .catch(() => null),
      ]);

      this.config = {
        openAiEndpoint:
          openAiEndpointSecret?.value ||
          process.env.AZURE_OPENAI_ENDPOINT ||
          "",
        openAiApiKey:
          openAiApiKeySecret?.value || process.env.AZURE_OPENAI_API_KEY || "",
        storageConnectionString:
          storageConnectionStringSecret?.value ||
          process.env.AzureWebJobsStorage ||
          "",
        keyVaultUri,
        applicationInsightsConnectionString:
          process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || "",
      };

      return this.config;
    } catch (error) {
      console.error("Erro ao carregar configuração:", error);

      // Fallback para variáveis de ambiente diretas
      this.config = {
        openAiEndpoint: process.env.AZURE_OPENAI_ENDPOINT || "",
        openAiApiKey: process.env.AZURE_OPENAI_API_KEY || "",
        storageConnectionString: process.env.AzureWebJobsStorage || "",
        keyVaultUri: process.env.KEY_VAULT_URI || "",
        applicationInsightsConnectionString:
          process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || "",
      };

      return this.config;
    }
  }

  public async getTableClient(): Promise<TableClient> {
    const config = await this.getConfig();
    return new TableClient(config.storageConnectionString, "RedmineAIHistory");
  }

  public async getBlobServiceClient(): Promise<BlobServiceClient> {
    const config = await this.getConfig();
    return new BlobServiceClient(config.storageConnectionString);
  }
}

export default ConfigService;
