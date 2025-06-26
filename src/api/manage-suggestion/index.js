module.exports = async function (context, req) {
    context.log('Managing suggestion...');

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
        const { activityId, userId, action, feedback, redmineData } = req.body || {};

        // Validate required fields
        if (!activityId || !userId || !action) {
            context.res = {
                status: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                },
                body: {
                    error: 'activityId, userId e action são obrigatórios'
                }
            };
            return;
        }

        // Validate action
        const validActions = ['approve', 'reject', 'modify', 'send_to_redmine'];
        if (!validActions.includes(action)) {
            context.res = {
                status: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                },
                body: {
                    error: `Ação inválida. Ações válidas: ${validActions.join(', ')}`
                }
            };
            return;
        }

        context.log(`Managing suggestion: ${activityId}, user: ${userId}, action: ${action}`);

        let response = {
            success: true,
            activityId: activityId,
            userId: userId,
            action: action,
            timestamp: new Date().toISOString()
        };

        switch (action) {
            case 'approve':
                response.newStatus = 'approved';
                response.message = 'Sugestão aprovada com sucesso';
                break;
            case 'reject':
                response.newStatus = 'rejected';
                response.message = 'Sugestão rejeitada';
                if (feedback) {
                    response.feedback = feedback;
                    response.message += ' com feedback';
                }
                break;
            case 'send_to_redmine':
                response.newStatus = 'sent_to_redmine';
                response.message = 'Sugestão enviada para o Redmine';
                if (redmineData) {
                    response.redmineTicketId = `TICKET_${Date.now()}`;
                    response.redmineProjectId = redmineData.projectId || 'default';
                }
                break;
        }

        context.res = {
            status: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
            },
            body: response
        };

    } catch (error) {
        context.log.error('Error managing suggestion:', error);
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
