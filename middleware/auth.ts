/**
 * Middleware de autenticación para proteger páginas
 * Redirige a usuarios no autenticados cuando se requiere autenticación
 */
export default defineNuxtRouteMiddleware((to, from) => {
  const { loggedIn } = useUserSession();
  const config = useRuntimeConfig();
  
  // Solo aplicar autenticación si está habilitada
  if (config.public.usingGithubAuth) {
    // Si el usuario no está autenticado, redirigir a la página principal
    // donde se mostrará la interfaz de login
    if (!loggedIn.value) {
      return navigateTo('/');
    }
  }
});
