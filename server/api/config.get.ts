// Endpoint para servir configuración dinámica
export default defineEventHandler(async (event) => {
  // Leer variables de entorno del servidor
  const config = {
    githubToken: process.env.NUXT_GITHUB_TOKEN || '',
    githubOrg: process.env.NUXT_PUBLIC_GITHUB_ORG || '',
    githubEnt: process.env.NUXT_PUBLIC_GITHUB_ENT || '',
    githubTeam: process.env.NUXT_PUBLIC_GITHUB_TEAM || '',
    scope: process.env.NUXT_PUBLIC_SCOPE || 'organization',
    isDataMocked: process.env.NUXT_PUBLIC_IS_DATA_MOCKED === 'true',
    usingGithubAuth: process.env.NUXT_PUBLIC_USING_GITHUB_AUTH === 'true',
    sessionPasswordLast4: (process.env.NUXT_SESSION_PASSWORD || '').slice(-4),
    githubClientIdLast4: (process.env.NUXT_OAUTH_GITHUB_CLIENT_ID || '').slice(-4),
    githubClientSecretLast4: (process.env.NUXT_OAUTH_GITHUB_CLIENT_SECRET || '').slice(-4),
    version: process.env.npm_package_version || '0.0.0'
  }

  return config
})
