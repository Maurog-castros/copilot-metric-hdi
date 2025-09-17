// Composable para validar la configuración del servidor
export const useConfigValidation = () => {
  const serverConfig = ref(null)
  const githubToken = ref(null)
  const orgAccess = ref(null)
  const loading = ref(false)
  const error = ref(null)

  const validateServerConfig = async () => {
    try {
      loading.value = true
      error.value = null
      
      const response = await $fetch('/api/validate/server-config')
      serverConfig.value = response
      return response
    } catch (err) {
      error.value = err
      console.error('Error validating server config:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const validateGitHubToken = async () => {
    try {
      loading.value = true
      error.value = null
      
      const response = await $fetch('/api/validate/github-token')
      githubToken.value = response
      return response
    } catch (err) {
      error.value = err
      console.error('Error validating GitHub token:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const validateOrgAccess = async () => {
    try {
      loading.value = true
      error.value = null
      
      const response = await $fetch('/api/validate/org-access')
      orgAccess.value = response
      return response
    } catch (err) {
      error.value = err
      console.error('Error validating organization access:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const validateAll = async () => {
    try {
      loading.value = true
      error.value = null
      
      const [serverResult, tokenResult, orgResult] = await Promise.all([
        validateServerConfig(),
        validateGitHubToken(),
        validateOrgAccess()
      ])

      return {
        serverConfig: serverResult,
        githubToken: tokenResult,
        orgAccess: orgResult,
        allValid: serverResult.valid && tokenResult.valid && orgResult.valid
      }
    } catch (err) {
      error.value = err
      console.error('Error validating all config:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    serverConfig: readonly(serverConfig),
    githubToken: readonly(githubToken),
    orgAccess: readonly(orgAccess),
    loading: readonly(loading),
    error: readonly(error),
    validateServerConfig,
    validateGitHubToken,
    validateOrgAccess,
    validateAll
  }
}
