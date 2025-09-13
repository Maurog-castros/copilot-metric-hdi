<template>
  <div class="setup-container">
    <v-container class="text-center py-16">
      <v-row justify="center">
        <v-col cols="12" md="8">
          <v-icon color="success" size="64">mdi-check-circle</v-icon>
          <h1 class="text-h4 mt-4 mb-2">✅ CopilotMetrics instalado con éxito</h1>
          <p class="text-body-1 mb-4">
            Tu aplicación ha sido instalada en la organización HDI Chile.<br>
            <span v-if="installationId">ID de instalación: <b>{{ installationId }}</b></span>
          </p>
          <v-btn color="primary" class="mt-4" :to="'/dashboard'">
            Ir al Dashboard
          </v-btn>
          <v-alert type="info" class="mt-6" border="start" variant="tonal">
            ¿Problemas? Contacta a soporte TI HDI.<br>
            <span class="text-caption">setup_action: {{ setupAction }}</span>
          </v-alert>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
const route = useRoute()
const installationId = ref<string | null>(null)
const setupAction = ref<string | null>(null)

onMounted(async () => {
  installationId.value = route.query.installation_id as string || null
  setupAction.value = route.query.setup_action as string || null
  // Llama al backend para registrar la instalación
  if (installationId.value) {
    try {
      await $fetch('/api/setup', {
        method: 'POST',
        body: {
          installation_id: installationId.value,
          setup_action: setupAction.value
        }
      })
    } catch (e) {
      // Ignorar error, solo log
      console.warn('No se pudo registrar la instalación:', e)
    }
  }
})
</script>

<style scoped>
.setup-container {
  min-height: 80vh;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
