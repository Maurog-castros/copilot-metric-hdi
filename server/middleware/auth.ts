import { authenticateAndGetGitHubHeaders } from '../modules/authentication';

// Mock getUserSession para cuando la autenticación está deshabilitada
async function getUserSession(event: any) {
    const config = useRuntimeConfig(event);
    
    // Si la autenticación GitHub está deshabilitada, devolver sesión mock
    if (!config.public.usingGithubAuth) {
        return {
            secure: {
                tokens: {
                    access_token: 'mock-token'
                },
                expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 horas desde ahora
            }
        };
    }
    
    // Si la autenticación está habilitada pero no hay implementación real, lanzar error
    throw new Error('GitHub authentication is enabled but getUserSession is not properly configured');
}

/**
 * Middleware de autenticación para proteger rutas específicas
 * Verifica si el usuario está autenticado antes de permitir el acceso
 */
export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig(event);
    const url = event.node.req.url || '';

    // Solo aplicar autenticación a rutas API específicas que requieren autenticación
    const protectedRoutes = [
        '/api/metrics',
        '/api/seats',
        '/api/teams'
    ];

    const isProtectedRoute = protectedRoutes.some(route => url.startsWith(route));
    
    if (!isProtectedRoute) {
        return;
    }

    // Si la autenticación GitHub está habilitada, verificar sesión
    if (config.public.usingGithubAuth) {
        try {
            // Verificar si hay una sesión de usuario válida
            const { secure } = await getUserSession(event);
            
            if (!secure?.tokens?.access_token) {
                throw createError({
                    statusCode: 401,
                    statusMessage: 'Authentication required. Please sign in with GitHub.',
                    data: {
                        error: 'UNAUTHORIZED',
                        message: 'No valid GitHub session found'
                    }
                });
            }

            // Verificar si el token ha expirado
            if (secure.expires_at && secure.expires_at < new Date()) {
                throw createError({
                    statusCode: 401,
                    statusMessage: 'Session expired. Please sign in again.',
                    data: {
                        error: 'SESSION_EXPIRED',
                        message: 'GitHub session has expired'
                    }
                });
            }

        } catch (error) {
            // Si hay un error de autenticación, devolver error 401
            if (error.statusCode === 401) {
                throw error;
            }
            
            // Para otros errores, log y devolver error genérico
            console.error('Authentication middleware error:', error);
            throw createError({
                statusCode: 500,
                statusMessage: 'Internal authentication error',
                data: {
                    error: 'AUTH_ERROR',
                    message: 'An error occurred during authentication'
                }
            });
        }
    }
});
