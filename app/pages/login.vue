<template>
  <v-container class="fill-height" fluid>
    <v-row align="center" justify="center">
      <v-col cols="12" sm="8" md="6" lg="4">
        <v-card class="elevation-12">
          <v-toolbar color="primary" dark flat>
            <v-toolbar-title>
              <v-icon left>mdi-shield-account</v-icon>
              Acceso HDI Copilot Metrics
            </v-toolbar-title>
          </v-toolbar>
          
          <v-card-text>
            <v-form @submit.prevent="handleLogin" ref="loginForm">
              <v-text-field
                v-model="credentials.username"
                label="Usuario"
                prepend-icon="mdi-account"
                type="text"
                :rules="[rules.required]"
                required
                autofocus
              />
              
              <v-text-field
                v-model="credentials.password"
                label="Contraseña"
                prepend-icon="mdi-lock"
                :type="showPassword ? 'text' : 'password'"
                :append-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
                @click:append="showPassword = !showPassword"
                :rules="[rules.required]"
                required
              />
            </v-form>
          </v-card-text>
          
          <v-card-actions>
            <v-spacer />
            <v-btn
              color="primary"
              @click="handleLogin"
              :loading="isLoading"
              :disabled="!isFormValid"
            >
              <v-icon left>mdi-login</v-icon>
              Iniciar Sesión
            </v-btn>
          </v-card-actions>
          
          <v-alert
            v-if="errorMessage"
            type="error"
            dismissible
            @click:close="errorMessage = ''"
            class="ma-4"
          >
            {{ errorMessage }}
          </v-alert>
        </v-card>
        
        <!-- Información adicional -->
        <v-card class="mt-4" variant="outlined">
          <v-card-text class="text-center">
            <v-icon color="info" class="mb-2">mdi-information</v-icon>
            <p class="text-body-2 mb-0">
              Acceso restringido para personal autorizado de HDI Seguros
            </p>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

// Configuración de la página
definePageMeta({
  layout: false,
  auth: false
})

// Estado del formulario
const credentials = ref({
  username: '',
  password: ''
})

const showPassword = ref(false)
const isLoading = ref(false)
const errorMessage = ref('')

// Reglas de validación
const rules = {
  required: (value: string) => !!value || 'Este campo es requerido'
}

// Validación del formulario
const isFormValid = computed(() => {
  return credentials.value.username && credentials.value.password
})

// Manejo del login
async function handleLogin() {
  if (!isFormValid.value) return
  
  isLoading.value = true
  errorMessage.value = ''
  
  try {
    const response = await $fetch('/api/auth/login', {
      method: 'POST',
      body: credentials.value
    })
    
    if (response.success) {
      // Redirigir al dashboard
      await navigateTo('/')
    } else {
      errorMessage.value = response.message || 'Error al iniciar sesión'
    }
  } catch (error: any) {
    console.error('Login error:', error)
    errorMessage.value = error.data?.message || 'Error de conexión. Intenta nuevamente.'
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
