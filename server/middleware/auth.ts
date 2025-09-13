import { authenticateAndGetGitHubHeaders } from '../modules/authentication';

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
            // Verificar si hay una sesión de usuario válida usando getUserSession de nuxt-auth-utils
            const session = await getUserSession(event);
            const secure = session?.secure;
            
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
    } else {
        // Si la autenticación está deshabilitada, permitir acceso sin verificación
        console.log('GitHub authentication is disabled, allowing access to protected routes');
    }
});
