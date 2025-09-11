import type { H3Event, EventHandlerRequest } from 'h3'

/**
 * Middleware de autenticación para proteger rutas
 * Verifica si el usuario está autenticado (OAuth GitHub o básico)
 */
export default defineEventHandler(async (event: H3Event<EventHandlerRequest>) => {
  const config = useRuntimeConfig(event)
  const path = getRouterParam(event, '_') || getRequestURL(event).pathname

  // Rutas que no requieren autenticación
  const publicRoutes = ['/login', '/auth/login', '/auth/github', '/health', '/api/health']
  
  // Si es una ruta pública, permitir acceso
  if (publicRoutes.some(route => path.startsWith(route))) {
    return
  }

  // Verificar si el usuario está autenticado
  const session = await getUserSession(event)
  
  // Verificar autenticación OAuth de GitHub
  if (config.public.usingGitHubAuth) {
    if (!session?.user?.githubId) {
      return sendRedirect(event, '/auth/login')
    }
  } else {
    // Verificar autenticación básica
    if (!session?.user?.isAuthenticated) {
      return sendRedirect(event, '/login')
    }
  }
})
