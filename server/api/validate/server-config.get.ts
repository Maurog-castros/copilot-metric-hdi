export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig(event)
  
  try {
    // Verificar configuración del servidor
    const hasGitHubToken = !!(config.githubToken && config.githubToken.length >= 10)
    const hasGitHubOrg = !!(config.public.githubOrg && config.public.githubOrg.length >= 2)
    const hasSessionPassword = !!(config.session.password && config.session.password.length >= 32)
    
    return {
      valid: hasGitHubToken && hasGitHubOrg && hasSessionPassword,
      githubToken: hasGitHubToken,
      githubOrg: hasGitHubOrg,
      sessionPassword: hasSessionPassword,
      githubOrgName: config.public.githubOrg,
      tokenLength: config.githubToken?.length || 0,
      sessionPasswordLast4: config.public.sessionPasswordLast4
    }
  } catch (error) {
    throw createError({
      statusCode: 500,
      statusMessage: 'Error validating server configuration',
      data: { error: error instanceof Error ? error.message : 'Unknown error' }
    })
  }
})
