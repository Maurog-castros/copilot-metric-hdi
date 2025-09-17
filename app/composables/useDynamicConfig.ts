// Composable para cargar configuración dinámicamente desde archivo JSON
export const useDynamicConfig = () => {
  const config = ref(null)
  const loading = ref(true)
  const error = ref(null)

  const loadConfig = async () => {
    try {
      loading.value = true
      error.value = null
      
      // Cargar configuración desde endpoint de API
      const data = await $fetch('/api/config')
      config.value = data
    } catch (err) {
      error.value = err
      console.error('Error loading dynamic config:', err)
      
      // Fallback a configuración por defecto
      config.value = {
        githubToken: '',
        githubOrg: 'hdicl',
        scope: 'organization',
        isDataMocked: true,
        usingGithubAuth: false,
        version: '0.0.0'
      }
    } finally {
      loading.value = false
    }
  }

  // Cargar configuración al inicializar
  onMounted(() => {
    loadConfig()
  })

  return {
    config: readonly(config),
    loading: readonly(loading),
    error: readonly(error),
    loadConfig
  }
}
