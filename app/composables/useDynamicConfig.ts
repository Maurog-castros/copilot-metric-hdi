// Composable para cargar configuración dinámicamente desde archivo JSON
import type { DynamicConfig, ValidationError } from '~/types/validation'

export const useDynamicConfig = () => {
  const config = ref<DynamicConfig | null>(null)
  const loading = ref(true)
  const error = ref<ValidationError | null>(null)

  const loadConfig = async () => {
    try {
      loading.value = true
      error.value = null
      
      // Cargar configuración desde endpoint de API
      const data = await $fetch<DynamicConfig>('/api/config')
      config.value = data
    } catch (err) {
      error.value = err as ValidationError
      console.error('Error loading dynamic config:', err)
      
      // Fallback a configuración por defecto
      config.value = {
        githubToken: '',
        githubOrg: 'hdicl',
        githubEnt: '',
        githubTeam: '',
        scope: 'organization',
        isDataMocked: true,
        usingGithubAuth: false,
        sessionPasswordLast4: '',
        githubClientIdLast4: '',
        githubClientSecretLast4: '',
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
