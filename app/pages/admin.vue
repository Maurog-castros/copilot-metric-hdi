<template>
  <div class="admin-container">
    <v-container>
      <v-row>
        <v-col cols="12">
          <v-card>
            <v-card-title class="bg-primary text-white">
              <v-icon left>mdi-server</v-icon>
              Panel de Administración - Logs del Servidor
            </v-card-title>
            
            <v-card-text>
              <v-row>
                <v-col cols="12" md="6">
                  <v-btn 
                    color="primary" 
                    @click="fetchLogs"
                    :loading="loadingLogs"
                    block
                  >
                    <v-icon left>mdi-refresh</v-icon>
                    Actualizar Logs
                  </v-btn>
                </v-col>
                
                <v-col cols="12" md="6">
                  <v-btn 
                    color="success" 
                    @click="fetchStatus"
                    :loading="loadingStatus"
                    block
                  >
                    <v-icon left>mdi-information</v-icon>
                    Estado del Servidor
                  </v-btn>
                </v-col>
              </v-row>
              
              <!-- Logs -->
              <v-card v-if="logs.length > 0" class="mt-4">
                <v-card-title>
                  <v-icon left>mdi-file-document-outline</v-icon>
                  Logs del Servidor (últimas 50 líneas)
                </v-card-title>
                <v-card-text>
                  <pre class="logs-content">{{ logs.join('\n') }}</pre>
                </v-card-text>
              </v-card>
              
              <!-- Estado del Servidor -->
              <v-card v-if="serverStatus" class="mt-4">
                <v-card-title>
                  <v-icon left>mdi-server-network</v-icon>
                  Estado del Servidor
                </v-card-title>
                <v-card-text>
                  <v-row>
                    <v-col cols="12" md="6">
                      <h4>Contenedor Docker:</h4>
                      <pre class="status-content">{{ serverStatus.container.info }}</pre>
                      
                      <h4>Uso de Memoria:</h4>
                      <pre class="status-content">{{ serverStatus.container.memory }}</pre>
                    </v-col>
                    
                    <v-col cols="12" md="6">
                      <h4>Información del Proceso:</h4>
                      <pre class="status-content">
PID: {{ serverStatus.server.pid }}
Uptime: {{ Math.round(serverStatus.server.uptime) }} segundos
Memoria: {{ Math.round(serverStatus.server.memory.heapUsed / 1024 / 1024) }} MB
                      </pre>
                    </v-col>
                  </v-row>
                </v-card-text>
              </v-card>
              
              <!-- Error -->
              <v-alert v-if="error" type="error" class="mt-4">
                {{ error }}
              </v-alert>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script setup lang="ts">
const logs = ref<string[]>([])
const serverStatus = ref<any>(null)
const loadingLogs = ref(false)
const loadingStatus = ref(false)
const error = ref('')

const fetchLogs = async () => {
  loadingLogs.value = true
  error.value = ''
  
  try {
    const response = await $fetch('/api/logs')
    if (response.success) {
      logs.value = response.logs
    } else {
      error.value = response.error
    }
  } catch (err) {
    error.value = `Error al obtener logs: ${err.message}`
  } finally {
    loadingLogs.value = false
  }
}

const fetchStatus = async () => {
  loadingStatus.value = true
  error.value = ''
  
  try {
    const response = await $fetch('/api/status')
    if (response.success) {
      serverStatus.value = response
    } else {
      error.value = response.error
    }
  } catch (err) {
    error.value = `Error al obtener estado: ${err.message}`
  } finally {
    loadingStatus.value = false
  }
}

// Auto-refresh cada 30 segundos
onMounted(() => {
  fetchLogs()
  fetchStatus()
  
  setInterval(() => {
    fetchLogs()
  }, 30000)
})
</script>

<style scoped>
.logs-content {
  background-color: #f5f5f5;
  padding: 16px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 12px;
  max-height: 400px;
  overflow-y: auto;
  white-space: pre-wrap;
}

.status-content {
  background-color: #e3f2fd;
  padding: 12px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 12px;
  white-space: pre-wrap;
}

.admin-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px 0;
}
</style>
