<template>
  <v-container class="fill-height" fluid>
    <v-row align="center" justify="center">
      <v-col cols="12" sm="8" md="6" lg="4">
        <v-card class="elevation-12">
          <v-toolbar color="primary" dark flat>
            <v-toolbar-title>
              <v-icon left>mdi-github</v-icon>
              Acceso HDI Copilot Metrics
            </v-toolbar-title>
          </v-toolbar>
          
          <v-card-text class="text-center pa-8">
            <v-icon size="64" color="primary" class="mb-4">mdi-chart-line</v-icon>
            
            <h2 class="text-h5 mb-4">Bienvenido a HDI Copilot Metrics</h2>
            
            <p class="text-body-1 mb-6 text-grey-darken-1">
              Accede con tu cuenta de GitHub para ver las métricas de Copilot de la organización HDI
            </p>
            
            <v-btn
              color="primary"
              size="large"
              @click="loginWithGitHub"
              :loading="isLoading"
              class="mb-4"
              block
            >
              <v-icon left>mdi-github</v-icon>
              Iniciar Sesión con GitHub
            </v-btn>
            
            <v-alert
              v-if="errorMessage"
              type="error"
              dismissible
              @click:close="errorMessage = ''"
              class="mt-4"
            >
              {{ errorMessage }}
            </v-alert>
          </v-card-text>
          
          <v-card-actions class="pa-4">
            <v-spacer />
            <v-chip
              color="info"
              variant="outlined"
              size="small"
            >
              <v-icon left>mdi-shield-check</v-icon>
              Acceso seguro con OAuth
            </v-chip>
          </v-card-actions>
        </v-card>
        
        <!-- Información adicional -->
        <v-card class="mt-4" variant="outlined">
          <v-card-text class="text-center">
            <v-icon color="info" class="mb-2">mdi-information</v-icon>
            <p class="text-body-2 mb-0">
              Solo miembros de la organización <strong>hdicl</strong> pueden acceder
            </p>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// Configuración de la página
definePageMeta({
  layout: false,
  auth: false
})

// Estado del componente
const isLoading = ref(false)
const errorMessage = ref('')

// Función para iniciar sesión con GitHub
async function loginWithGitHub() {
  isLoading.value = true
  errorMessage.value = ''
  
  try {
    // Redirigir a la ruta de OAuth de GitHub
    await navigateTo('/auth/github', { external: true })
  } catch (error: any) {
    console.error('GitHub OAuth error:', error)
    errorMessage.value = 'Error al iniciar sesión con GitHub. Intenta nuevamente.'
  } finally {
    isLoading.value = false
  }
}

// Headers de la página
useHead({
  title: 'Login - HDI Copilot Metrics'
})
</script>

<style scoped>
.fill-height {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}
</style>
