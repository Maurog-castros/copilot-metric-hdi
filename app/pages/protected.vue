<template>
  <div class="protected-page">
    <v-container>
      <v-row justify="center">
        <v-col cols="12" md="8">
          <v-card elevation="4" class="pa-6">
            <v-card-title class="text-h4 text-center mb-4">
              <v-icon color="success" size="48" class="mr-3">mdi-shield-check</v-icon>
              Página Protegida
            </v-card-title>
            
            <v-card-text>
              <v-alert type="success" variant="tonal" class="mb-4">
                <v-alert-title>Acceso Autorizado</v-alert-title>
                Esta página solo es accesible para usuarios autenticados con GitHub.
              </v-alert>
              
              <div class="user-info-section">
                <h3 class="text-h6 mb-3">Información del Usuario</h3>
                <v-list>
                  <v-list-item>
                    <template #prepend>
                      <v-avatar>
                        <v-img :src="user?.avatarUrl" :alt="user?.name" />
                      </v-avatar>
                    </template>
                    <v-list-item-title>{{ user?.name }}</v-list-item-title>
                    <v-list-item-subtitle>Usuario autenticado con GitHub</v-list-item-subtitle>
                  </v-list-item>
                </v-list>
              </div>
              
              <div class="actions-section mt-6">
                <v-btn 
                  color="primary" 
                  variant="elevated"
                  @click="goToMain"
                  class="mr-3"
                >
                  <v-icon left>mdi-chart-line</v-icon>
                  Ir a Métricas
                </v-btn>
                
                <v-btn 
                  color="error" 
                  variant="outlined"
                  @click="logout"
                >
                  <v-icon left>mdi-logout</v-icon>
                  Cerrar Sesión
                </v-btn>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script setup lang="ts">
// Aplicar middleware de autenticación
definePageMeta({
  middleware: ['auth']
});

const { user, clear } = useUserSession();

const goToMain = () => {
  navigateTo('/');
};

const logout = () => {
  clear();
  navigateTo('/');
};
</script>

<style scoped>
.protected-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding: 2rem 0;
}

.user-info-section {
  background: rgba(76, 175, 80, 0.1);
  border-radius: 8px;
  padding: 1rem;
  border-left: 4px solid #4caf50;
}

.actions-section {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

@media (max-width: 768px) {
  .actions-section {
    flex-direction: column;
  }
}
</style>
