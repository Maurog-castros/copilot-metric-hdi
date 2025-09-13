interface GitHubOrg {
  login: string
  name?: string
}

interface CopilotSeatsResponse {
  seats: Array<{
    id: number
    [key: string]: any
  }>
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

    const orgName = config.public.githubOrg || 'hdicl'
    
    // Verificar acceso a la organización
    const orgResponse = await $fetch<GitHubOrg>(`https://api.github.com/orgs/${orgName}`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'Copilot-Metrics-Viewer'
      }
    })

    if (!orgResponse || !orgResponse.login) {
      return {
        valid: false,
        error: `No se pudo acceder a la organización ${orgName}`
      }
    }

    // Verificar acceso a datos de Copilot
    let copilotSeats = 0
    try {
      const copilotResponse = await $fetch<CopilotSeatsResponse>(`https://api.github.com/orgs/${orgName}/copilot/billing/seats`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Copilot-Metrics-Viewer'
        }
      })

      if (copilotResponse && copilotResponse.seats) {
        copilotSeats = copilotResponse.seats.length
      }
    } catch (copilotError: any) {
      if (copilotError.status === 404) {
        return {
          valid: false,
          error: `La organización ${orgName} no tiene Copilot habilitado`
        }
      } else if (copilotError.status === 403) {
        return {
          valid: false,
          error: `Sin permisos para acceder a datos de Copilot de ${orgName}`
        }
      } else {
        return {
          valid: false,
          error: `Error accediendo a datos de Copilot: ${copilotError.message}`
        }
      }
    }

    return {
      valid: true,
      orgName: orgResponse.login,
      orgDisplayName: orgResponse.name || orgResponse.login,
      copilotSeats,
      message: `Acceso confirmado a ${orgResponse.login}`
    }

  } catch (error: any) {
    logger.error('Error validating organization access:', error)
    
    if (error.status === 404) {
      return {
        valid: false,
        error: 'Organización no encontrada'
      }
    } else if (error.status === 403) {
      return {
        valid: false,
        error: 'Sin permisos para acceder a la organización'
      }
    } else if (error.status === 401) {
      return {
        valid: false,
        error: 'Token inválido o expirado'
      }
    } else {
      return {
        valid: false,
        error: `Error de conexión: ${error.message || 'Error desconocido'}`
      }
    }
  }
})
