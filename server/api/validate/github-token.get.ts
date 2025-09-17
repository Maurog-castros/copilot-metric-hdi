interface GitHubUser {
  login: string
  name?: string
  email?: string
  id: number
}

export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig(event)
  const logger = console

  try {
    // Verificar si hay token configurado
    const token = config.githubToken || process.env.NUXT_GITHUB_TOKEN
    
    if (!token) {
      return {
        valid: false,
        error: 'No hay token de GitHub configurado'
      }
    }

    // Validar el token haciendo una petición a la API de GitHub
    const response = await $fetch<GitHubUser>('https://api.github.com/user', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'Copilot-Metrics-Viewer-HDI'
      }
    })

    if (response && response.login) {
      return {
        valid: true,
        user: {
          login: response.login,
          name: response.name,
          email: response.email,
          id: response.id
        },
        message: 'Token válido'
      }
    } else {
      return {
        valid: false,
        error: 'Respuesta inválida de GitHub API'
      }
    }

  } catch (error: any) {
    logger.error('Error validating GitHub token:', error)
    
    if (error.status === 401) {
      return {
        valid: false,
        error: 'Token inválido o expirado'
      }
    } else if (error.status === 403) {
      return {
        valid: false,
        error: 'Token sin permisos suficientes'
      }
    } else if (error.status === 429) {
      return {
        valid: false,
        error: 'Límite de rate limit excedido'
      }
    } else {
      return {
        valid: false,
        error: `Error de conexión: ${error.message || 'Error desconocido'}`
      }
    }
  }
})
