module.exports = async function (context, req) {
    context.log('Retrieving activity history...');

    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        context.res = {
            status: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            }
        };
        return;
    }

    try {
        const url = new URL(`http://localhost${req.url}`);
        const userId = url.searchParams.get('userId');
        const activityType = url.searchParams.get('activityType');
        const status = url.searchParams.get('status');
        const page = parseInt(url.searchParams.get('page') || '1');
        const limit = parseInt(url.searchParams.get('limit') || '10');

        if (!userId) {
            context.res = {
                status: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                },
                body: {
                    error: 'userId é obrigatório'
                }
            };
            return;
        }

        context.log(`Getting activity history for user: ${userId}`);

        // Mock data
        const mockActivities = [
            {
                id: 'act_001',
                userId: userId,
                activityType: 'Desenvolvimento',
                description: 'Implementação de nova funcionalidade de relatórios',
                suggestion: 'Sistema de relatórios automatizados com dashboard interativo',
                confidence: 0.92,
                status: 'approved',
                createdAt: new Date(Date.now() - 3600000),
                updatedAt: new Date(Date.now() - 1800000),
                redmineTicketId: 'TICKET_12345',
                timeSpent: 4.5,
                evidenceIds: ['evidence_001', 'evidence_002']
            }
        ];

        const response = {
            data: mockActivities,
            total: mockActivities.length,
            page: page,
            limit: limit,
            totalPages: 1
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
        context.log.error('Error retrieving activity history:', error);
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
