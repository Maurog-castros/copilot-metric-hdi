<template>
  <v-dialog
    v-model="isOpen"
    persistent
    max-width="800"
    scrollable
  >
    <v-card>
      <v-card-title class="d-flex align-center">
        <v-icon class="mr-3" color="primary">mdi-shield-check</v-icon>
        <span class="text-h5">Validación de Configuración</span>
      </v-card-title>

      <v-card-text class="pa-6">
        <div class="text-body-1 mb-4">
          Verificando la configuración de las API keys y servicios...
        </div>

        <v-list class="elevation-1 rounded">
          <v-list-item
            v-for="(item, index) in validationItems"
            :key="index"
            class="px-4"
          >
            <template #prepend>
              <v-progress-circular
                v-if="item.status === 'checking'"
                indeterminate
                size="24"
                color="primary"
                class="mr-3"
              />
              <v-icon
                v-else-if="item.status === 'success'"
                color="success"
                class="mr-3"
              >
                mdi-check-circle
              </v-icon>
              <v-icon
                v-else-if="item.status === 'error'"
                color="error"
                class="mr-3"
              >
                mdi-alert-circle
              </v-icon>
              <v-icon
                v-else
                color="grey"
                class="mr-3"
              >
                mdi-help-circle
              </v-icon>
            </template>

            <v-list-item-title class="font-weight-medium">
              {{ item.title }}
            </v-list-item-title>

            <v-list-item-subtitle>
              {{ item.description }}
            </v-list-item-subtitle>

            <template #append>
              <v-chip
                :color="getStatusColor(item.status)"
                :variant="item.status === 'success' ? 'flat' : 'outlined'"
                size="small"
              >
                {{ getStatusText(item.status) }}
              </v-chip>
            </template>
          </v-list-item>
        </v-list>

        <v-alert
          v-if="hasErrors"
          type="error"
          variant="tonal"
          class="mt-4"
        >
          <v-alert-title>Errores de Configuración</v-alert-title>
          <div class="mt-2">
            <div v-for="error in errorMessages" :key="error" class="text-body-2">
              • {{ error }}
            </div>
          </div>
        </v-alert>

        <v-alert
          v-if="allValidationsComplete && !hasErrors"
          type="success"
          variant="tonal"
          class="mt-4"
        >
          <v-alert-title>¡Configuración Completa!</v-alert-title>
          <div class="text-body-2 mt-2">
            Todas las API keys y servicios están configurados correctamente.
          </div>
        </v-alert>
      </v-card-text>

      <v-card-actions class="pa-4">
        <v-spacer />
        <v-btn
          v-if="!allValidationsComplete"
          color="primary"
          variant="outlined"
          @click="startValidation"
          :loading="isValidating"
        >
          <v-icon start>mdi-refresh</v-icon>
          Revalidar
        </v-btn>
        <v-btn
          v-if="allValidationsComplete"
          color="success"
          @click="closeModal"
        >
          <v-icon start>mdi-check</v-icon>
          Continuar
        </v-btn>
        <v-btn
          v-if="hasErrors"
          color="warning"
          variant="outlined"
          @click="closeModal"
        >
          <v-icon start>mdi-arrow-right</v-icon>
          Continuar de Todas Formas
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
interface ValidationItem {
  id: string
  title: string
  description: string
  status: 'pending' | 'checking' | 'success' | 'error'
  errorMessage?: string
}

const isOpen = ref(true)
const isValidating = ref(false)
const validationItems = ref<ValidationItem[]>([
  {
    id: 'github-oauth',
    title: 'GitHub OAuth App',
    description: 'Configuración de OAuth para autenticación de usuarios',
    status: 'pending'
  },
  {
    id: 'github-app',
    title: 'GitHub App (Datos)',
    description: 'Configuración de GitHub App para acceso a métricas de Copilot',
    status: 'pending'
  },
  {
    id: 'session-config',
    title: 'Configuración de Sesión',
    description: 'Password de encriptación de sesiones',
    status: 'pending'
  },
  {
    id: 'oauth-flow',
    title: 'Flujo de Autenticación',
    description: 'Verificar que el flujo OAuth funcione correctamente',
    status: 'pending'
  }
])

const allValidationsComplete = computed(() => {
  return validationItems.value.every(item =>
    item.status === 'success' || item.status === 'error'
  )
})

const hasErrors = computed(() => {
  return validationItems.value.some(item => item.status === 'error')
})

const errorMessages = computed(() => {
  return validationItems.value
    .filter(item => item.status === 'error')
    .map(item => item.errorMessage || `${item.title}: Error desconocido`)
})

const getStatusColor = (status: string) => {
  switch (status) {
    case 'success': return 'success'
    case 'error': return 'error'
    case 'checking': return 'primary'
    default: return 'grey'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'success': return 'Válido'
    case 'error': return 'Error'
    case 'checking': return 'Verificando...'
    default: return 'Pendiente'
  }
}

const startValidation = async () => {
  isValidating.value = true

  // Reset all items to pending
  validationItems.value.forEach(item => {
    item.status = 'pending'
  })

  // Validate each item sequentially
  for (const item of validationItems.value) {
    await validateItem(item)
    // Small delay between validations for better UX
    await new Promise(resolve => setTimeout(resolve, 500))
  }

  isValidating.value = false
}

const validateItem = async (item: ValidationItem) => {
  item.status = 'checking'

  try {
    switch (item.id) {
      case 'github-oauth':
        await validateGitHubOAuth(item)
        break
      case 'github-app':
        await validateGitHubApp(item)
        break
      case 'session-config':
        await validateSessionConfig(item)
        break
      case 'oauth-flow':
        await validateOAuthFlow(item)
        break
      default:
        item.status = 'error'
        item.errorMessage = 'Validación no implementada'
    }
  } catch (error) {
    item.status = 'error'
    item.errorMessage = error instanceof Error ? error.message : 'Error desconocido'
  }
}

const validateGitHubApp = async (item: ValidationItem) => {
  try {
    const response = await $fetch<{
      valid: boolean
      githubToken: boolean
      githubOrg: boolean
      sessionPassword: boolean
      githubOrgName?: string
      tokenLength?: number
      sessionPasswordLast4?: string
    }>('/api/validate/server-config', {
      method: 'GET'
    })

    if (response.valid) {
      item.status = 'success'
      item.description = `GitHub App configurada para organización: ${response.githubOrgName}`
    } else {
      const errors = []
      if (!response.githubToken) errors.push(`GitHub Token (${response.tokenLength || 0} caracteres)`)
      if (!response.githubOrg) errors.push('Organización GitHub')
      if (!response.sessionPassword) errors.push('Password de sesión')
      
      item.status = 'error'
      item.errorMessage = `Faltan: ${errors.join(', ')}`
    }
  } catch (error) {
    item.status = 'error'
    item.errorMessage = 'No se pudo validar la configuración del servidor'
  }
}

const validateGitHubOAuth = async (item: ValidationItem) => {
  const config = useRuntimeConfig()
  
  const clientIdLast4 = config.public.githubClientIdLast4
  const clientSecretLast4 = config.public.githubClientSecretLast4

  if (!config.public.usingGithubAuth) {
    item.status = 'success'
    item.description = 'OAuth deshabilitado (modo desarrollo)'
    return
  }

  if (typeof clientIdLast4 !== 'string' || clientIdLast4.length < 4 || typeof clientSecretLast4 !== 'string' || clientSecretLast4.length < 4) {
    item.status = 'error'
    item.errorMessage = 'Client ID o Client Secret faltantes'
    return
  }

  item.status = 'success'
  item.description = `OAuth configurado correctamente (Client ID ...${clientIdLast4}, Secret ...${clientSecretLast4})`
}

const validateOAuthFlow = async (item: ValidationItem) => {
  try {
    // Verificar que la ruta de autenticación responde correctamente
    const response = await $fetch('/auth/github', {
      method: 'HEAD'
    })

    // Si llegamos aquí, la ruta responde (probablemente con redirección)
    item.status = 'success'
    item.description = 'Flujo OAuth funcionando correctamente'
  } catch (error) {
    // Verificar si es un error de redirección (que es esperado)
    if (error && typeof error === 'object' && 'status' in error) {
      const status = (error as any).status
      if (status === 302 || status === 200) {
        item.status = 'success'
        item.description = 'Flujo OAuth funcionando correctamente'
        return
      }
    }
    
    item.status = 'error'
    item.errorMessage = 'No se pudo verificar el flujo OAuth'
  }
}


const validateSessionConfig = async (item: ValidationItem) => {
  const config = useRuntimeConfig()
  
  const last4 = config.public.sessionPasswordLast4
  if (typeof last4 !== 'string' || last4.length < 4) {
    item.status = 'error'
    item.errorMessage = 'Password de sesión debe tener al menos 32 caracteres'
    return
  }
  item.status = 'success'
  item.description = `Configuración de sesión válida (termina en ...${last4})`
}

const closeModal = () => {
  isOpen.value = false
  // Emit event to parent component
  emit('close')
}

const emit = defineEmits<{
  close: []
}>()

// Start validation when component mounts
onMounted(() => {
  startValidation()
})
</script>

<style scoped>
.v-list-item {
  border-bottom: 1px solid rgba(var(--v-border-color), var(--v-border-opacity));
}

.v-list-item:last-child {
  border-bottom: none;
}
</style>
