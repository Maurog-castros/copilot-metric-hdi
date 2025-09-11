/**
 * Endpoint para obtener la configuración de autenticación
 * Útil para el frontend para saber qué tipo de autenticación está habilitada
 */
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig(event);
  
  return {
    usingGithubAuth: config.public.usingGithubAuth,
    isDataMocked: config.public.isDataMocked,
    githubOrg: config.public.githubOrg,
    githubEnt: config.public.githubEnt,
    githubTeam: config.public.githubTeam,
    scope: config.public.scope,
    version: config.public.version
  };
});
