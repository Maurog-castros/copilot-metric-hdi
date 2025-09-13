export default defineEventHandler((event) => {
  const url = getRequestURL(event);
  const search = url.search || '';
  // Reenviar el callback de GitHub a la ruta manejada por nuxt-auth-utils
  // Conserva code/state u otros parámetros
  return sendRedirect(event, `/auth/github${search}`);
});


