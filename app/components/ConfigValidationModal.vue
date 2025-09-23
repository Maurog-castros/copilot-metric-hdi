<template>
  <v-dialog v-model="showModal" max-width="800" persistent>
    <v-card>
      <v-card-title class="text-h5 bg-primary text-white">
        <v-icon left>mdi-cog</v-icon>
        Validación de Configuración
      </v-card-title>

      <v-card-text class="pa-4">
        <div v-if="loading" class="text-center py-4">
          <v-progress-circular indeterminate color="primary" />
          <p class="mt-2">Validando configuración...</p>
        </div>

        <div v-else>
          <!-- Configuración del Servidor -->
          <v-card variant="outlined" class="mb-4">
            <v-card-title class="text-h6">
              <v-icon :color="serverConfig?.valid ? 'success' : 'error'" class="mr-2">
                {{ serverConfig?.valid ? 'mdi-check-circle' : 'mdi-alert-circle' }}
              </v-icon>
              Configuración del Servidor
            </v-card-title>
            <v-card-text>
              <v-list density="compact">
                <v-list-item>
                  <v-list-item-title>Token de GitHub</v-list-item-title>
                  <template v-slot:append>
                    <v-chip :color="serverConfig?.githubToken ? 'success' : 'error'" size="small">
                      {{ serverConfig?.githubToken ? 'Válido' : 'Inválido' }}
                    </v-chip>
                  </template>
                </v-list-item>
                <v-list-item>
                  <v-list-item-title>Organización GitHub</v-list-item-title>
                  <template v-slot:append>
                    <v-chip :color="serverConfig?.githubOrg ? 'success' : 'error'" size="small">
                      {{ serverConfig?.githubOrg ? serverConfig.githubOrgName : 'No configurada' }}
                    </v-chip>
                  </template>
                </v-list-item>
                <v-list-item>
                  <v-list-item-title>Password de Sesión</v-list-item-title>
                  <template v-slot:append>
                    <v-chip :color="serverConfig?.sessionPassword ? 'success' : 'error'" size="small">
                      {{ serverConfig?.sessionPassword ? 'Configurado' : 'No configurado' }}
                    </v-chip>
                  </template>
                </v-list-item>
              </v-list>
            </v-card-text>
          </v-card>

          <!-- Validación del Token GitHub -->
          <v-card variant="outlined" class="mb-4">
            <v-card-title class="text-h6">
              <v-icon :color="githubToken?.valid ? 'success' : 'error'" class="mr-2">
                {{ githubToken?.valid ? 'mdi-check-circle' : 'mdi-alert-circle' }}
              </v-icon>
              Token de GitHub
            </v-card-title>
            <v-card-text>
              <div v-if="githubToken?.valid">
                <p class="text-success">✅ Token válido</p>
                <p><strong>Usuario:</strong> {{ githubToken.user?.login }}</p>
                <p v-if="githubToken.user?.name"><strong>Nombre:</strong> {{ githubToken.user.name }}</p>
                <p v-if="githubToken.user?.email"><strong>Email:</strong> {{ githubToken.user.email }}</p>
              </div>
              <div v-else>
                <p class="text-error">❌ {{ githubToken?.error || 'Error desconocido' }}</p>
              </div>
            </v-card-text>
          </v-card>

          <!-- Acceso a la Organización -->
          <v-card variant="outlined">
            <v-card-title class="text-h6">
              <v-icon :color="orgAccess?.valid ? 'success' : 'error'" class="mr-2">
                {{ orgAccess?.valid ? 'mdi-check-circle' : 'mdi-alert-circle' }}
              </v-icon>
              Acceso a la Organización
            </v-card-title>
            <v-card-text>
              <div v-if="orgAccess?.valid">
                <p class="text-success">✅ Acceso confirmado</p>
                <p><strong>Organización:</strong> {{ orgAccess.orgDisplayName }}</p>
                <p><strong>Asientos de Copilot:</strong> {{ orgAccess.copilotSeats }}</p>
              </div>
              <div v-else>
                <p class="text-error">❌ {{ orgAccess?.error || 'Error desconocido' }}</p>
              </div>
            </v-card-text>
          </v-card>

          <v-alert v-if="error" type="error" class="mt-4">
            Error durante la validación: {{ error?.message || 'Error desconocido' }}
          </v-alert>
        </div>
      </v-card-text>

      <v-card-actions>
        <v-spacer />
        <v-btn @click="revalidate" :loading="loading" color="primary">
          <v-icon left>mdi-refresh</v-icon>
          Revalidar
        </v-btn>
        <v-btn @click="closeModal" :disabled="loading">
          Cerrar
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup lang="ts">
const showModal = ref(false)
const { serverConfig, githubToken, orgAccess, loading, error, validateAll } = useConfigValidation()

const emit = defineEmits<{
  close: []
}>()

const openModal = async () => {
  showModal.value = true
  await validateAll()
}

const revalidate = async () => {
  await validateAll()
}

const closeModal = () => {
  showModal.value = false
  emit('close')
}

// Exponer método para abrir el modal
defineExpose({
  openModal
})
</script>
