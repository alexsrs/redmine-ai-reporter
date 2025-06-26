module.exports = async function (context, req) {
    context.log('Uploading evidence...');

    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        context.res = {
            status: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            }
        };
        return;
    }

    try {
        const { userId, fileName, fileContent, fileType, activityType, description } = req.body || {};

        // Validate required fields
        if (!userId || !fileName || !fileContent || !fileType) {
            context.res = {
                status: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                },
                body: {
                    error: 'userId, fileName, fileContent e fileType são obrigatórios'
                }
            };
            return;
        }

        // Validate file type
        const allowedTypes = [
            'image/jpeg', 'image/png', 'image/gif', 'image/webp',
            'application/pdf', 'text/plain', 'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        ];

        if (!allowedTypes.includes(fileType)) {
            context.res = {
                status: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                },
                body: {
                    error: 'Tipo de arquivo não permitido',
                    allowedTypes: allowedTypes
                }
            };
            return;
        }

        context.log(`Uploading evidence: ${fileName} (${fileType}) for user: ${userId}`);

        // Generate mock file ID and URL
        const evidenceId = `evidence_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const fileUrl = `https://mockstorageaccount.blob.core.windows.net/evidences/${evidenceId}`;

        const response = {
            success: true,
            evidenceId: evidenceId,
            fileName: fileName,
            fileType: fileType,
            fileUrl: fileUrl,
            userId: userId,
            activityType: activityType || 'general',
            description: description || '',
            uploadedAt: new Date().toISOString(),
            status: 'uploaded'
        };

        context.res = {
            status: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
            },
            body: response
        };

    } catch (error) {
        context.log.error('Error uploading evidence:', error);
        context.res = {
            status: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
            },
            body: {
                error: 'Erro interno do servidor',
                details: error.message
            }
        };
    }
};
