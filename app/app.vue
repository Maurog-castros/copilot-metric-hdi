<template>
  <div>
    <!-- Modal de validación de API keys -->
    <ApiKeysValidationModal 
      v-if="showValidationModal"
      @close="handleValidationClose"
    />
    
    <!-- Contenido principal de la aplicación -->
    <NuxtLayout v-if="!showValidationModal">
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
// Estado para controlar la visibilidad del modal de validación
const showValidationModal = ref(true)

// Función para manejar el cierre del modal
const handleValidationClose = () => {
  showValidationModal.value = false
  sessionStorage.setItem('api-keys-validated', 'true')
}

// Verificar si ya se validó previamente (opcional - puedes usar localStorage)
onMounted(() => {
  // Opcional: verificar si ya se validó en esta sesión
  const hasValidated = sessionStorage.getItem('api-keys-validated')
  if (hasValidated === 'true') {
    showValidationModal.value = false
  }
})
</script>