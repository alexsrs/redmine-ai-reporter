import {
  app,
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from "@azure/functions";
import { BlobServiceClient } from "@azure/storage-blob";
import { TableClient } from "@azure/data-tables";
import { v4 as uuidv4 } from "uuid";
import ConfigService from "../config";

/**
 * Azure Function para upload de evidências (arquivos, capturas de tela)
 * Armazena arquivos no Blob Storage e metadados no Table Storage
 */
export async function uploadEvidence(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log("Função uploadEvidence iniciada");

  // CORS preflight
  if (request.method === "OPTIONS") {
    return {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    };
  }

  if (request.method !== "POST") {
    return {
      status: 405,
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
      jsonBody: { error: "Método não permitido" },
    };
  }

  try {
    const configService = ConfigService.getInstance();
    const config = await configService.getConfig();

    // Para demonstração, vamos usar uma abordagem simplificada
    // Em produção real, usaria bibliotecas como 'multer' ou 'multiparty'
    const requestBody = await request.text();
    const requestData = JSON.parse(requestBody || "{}");

    const {
      userId,
      fileName,
      fileContent,
      fileType,
      activityType,
      description,
    } = requestData;

    if (!userId || !fileName || !fileContent) {
      return {
        status: 400,
        headers: { "Access-Control-Allow-Origin": "*" },
        jsonBody: { error: "userId, fileName e fileContent são obrigatórios" },
      };
    }

    // Validação de tipo de arquivo
    const allowedTypes = [
      "image/png",
      "image/jpeg",
      "image/gif",
      "application/pdf",
      "text/plain",
    ];
    if (fileType && !allowedTypes.includes(fileType)) {
      return {
        status: 400,
        headers: { "Access-Control-Allow-Origin": "*" },
        jsonBody: { error: "Tipo de arquivo não suportado" },
      };
    }

    const evidenceId = uuidv4();
    const sanitizedFileName = `${evidenceId}-${fileName.replace(
      /[^a-zA-Z0-9.-]/g,
      "_"
    )}`;
    const containerName = "evidencias";

    // Upload para Blob Storage
    const blobServiceClient = BlobServiceClient.fromConnectionString(
      config.storageConnectionString
    );
    const containerClient = blobServiceClient.getContainerClient(containerName);

    // Garante que o container existe
    await containerClient.createIfNotExists({
      access: "blob",
    });

    const blockBlobClient =
      containerClient.getBlockBlobClient(sanitizedFileName);

    // Converte base64 para buffer (assumindo que fileContent é base64)
    const buffer = Buffer.from(fileContent, "base64");

    await blockBlobClient.upload(buffer, buffer.length, {
      blobHTTPHeaders: {
        blobContentType: fileType || "application/octet-stream",
      },
      metadata: {
        originalName: fileName,
        userId: userId,
        activityType: activityType || "unknown",
        description: description || "",
        uploadDate: new Date().toISOString(),
      },
    });

    // Salva metadados no Table Storage
    const tableClient = new TableClient(
      config.storageConnectionString,
      "evidences"
    );
    await tableClient.createTable();

    const entity = {
      partitionKey: userId,
      rowKey: evidenceId,
      fileName: sanitizedFileName,
      originalName: fileName,
      fileSize: buffer.length,
      fileType: fileType || "application/octet-stream",
      activityType: activityType || "unknown",
      description: description || "",
      blobUrl: blockBlobClient.url,
      uploadDate: new Date(),
      status: "uploaded",
    };

    await tableClient.createEntity(entity);

    const response = {
      success: true,
      evidenceId: evidenceId,
      fileName: sanitizedFileName,
      url: blockBlobClient.url,
      message: "Evidência enviada com sucesso",
    };

    context.log("Upload de evidência concluído:", evidenceId);

    return {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
      jsonBody: response,
    };
  } catch (error) {
    context.error("Erro no upload de evidência:", error);

    const errorMessage =
      error instanceof Error ? error.message : "Erro desconhecido";

    return {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      jsonBody: {
        error: "Erro interno do servidor",
        details:
          process.env.NODE_ENV === "development" ? errorMessage : undefined,
      },
    };
  }
}

app.http("uploadEvidence", {
  methods: ["GET", "POST", "OPTIONS"],
  authLevel: "anonymous",
  route: "upload-evidence",
  handler: uploadEvidence,
});
