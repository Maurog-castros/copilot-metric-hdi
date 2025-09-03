<template>
  <div class="org-selector-container">
    <v-card class="org-selector-card" elevation="2">
      <v-card-title class="org-selector-title">
        <v-icon class="mr-2" color="white">mdi-office-building</v-icon>
        Seleccionar Organización
      </v-card-title>
      
      <v-card-text class="org-selector-content">
        <div class="org-select-wrapper">
          <v-select
            v-model="selectedOrg"
            :items="availableOrganizations"
            label="Organización"
            variant="outlined"
            density="compact"
            @update:model-value="onOrganizationChange"
            class="org-select"
            hide-details
            color="success"
          >
            <template v-slot:prepend-inner>
              <v-icon color="success">mdi-github</v-icon>
            </template>
          </v-select>
        </div>
        
        <div class="org-info mt-4">
          <v-chip 
            :color="getOrgColor(selectedOrg)" 
            variant="tonal"
            class="org-chip"
            size="large"
          >
            <v-icon start size="20">{{ getOrgIcon(selectedOrg) }}</v-icon>
            {{ getOrgDisplayName(selectedOrg) }}
          </v-chip>
          
          <div class="org-description mt-2">
            <span class="text-body-2 text-medium-emphasis">
              {{ getOrgDescription(selectedOrg) }}
            </span>
          </div>
        </div>
        
        <div class="org-stats mt-3">
          <v-row>
            <v-col cols="6">
              <div class="stat-item">
                <div class="stat-value">{{ getOrgStats(selectedOrg).repos }}</div>
                <div class="stat-label">Repositorios</div>
              </div>
            </v-col>
            <v-col cols="6">
              <div class="stat-item">
                <div class="stat-value">{{ getOrgStats(selectedOrg).members }}</div>
                <div class="stat-label">Miembros</div>
              </div>
            </v-col>
          </v-row>
        </div>
      </v-card-text>
      
      <v-card-actions class="org-selector-actions">
        <v-btn
          variant="text"
          color="success"
          @click="refreshOrgData"
          :loading="isRefreshing"
          prepend-icon="mdi-refresh"
        >
          Actualizar Datos
        </v-btn>
        
        <v-spacer></v-spacer>
        
        <v-btn
          variant="outlined"
          color="info"
          @click="showOrgDetails"
          prepend-icon="mdi-information"
        >
          Ver Detalles
        </v-btn>
      </v-card-actions>
    </v-card>
  </div>
</template>

<script setup lang="ts">
import { ORGANIZATIONS, type Organization } from '@/config/organizations';

const props = defineProps({
  organizations: {
    type: Array as PropType<string[]>,
    default: () => ['hdicl', 'HDISeguros-cl']
  },
  currentOrg: {
    type: String,
    default: 'hdicl'
  }
})

const emit = defineEmits<{
  'organization-changed': [org: string];
  'refresh-requested': [org: string];
}>()

const selectedOrg = ref(props.currentOrg)
const isRefreshing = ref(false)

// Usar la configuración centralizada
const organizationConfig = ORGANIZATIONS;

const availableOrganizations = computed(() => 
  props.organizations.map(org => ({
    title: organizationConfig[org]?.title || org,
    value: org
  })).filter(org => organizationConfig[org.value]) // Solo incluir organizaciones válidas
)

const getOrgDisplayName = (org: string): string => {
  return organizationConfig[org]?.title || org
}

const getOrgColor = (org: string): string => {
  return organizationConfig[org]?.color || 'default'
}

const getOrgIcon = (org: string): string => {
  return organizationConfig[org]?.icon || 'mdi-github'
}

const getOrgDescription = (org: string): string => {
  return organizationConfig[org]?.description || 'Organización de GitHub'
}

const getOrgStats = (org: string) => {
  return {
    repos: organizationConfig[org]?.repos || 0,
    members: organizationConfig[org]?.members || 0
  }
}

const onOrganizationChange = (newOrg: string) => {
  console.log(`Cambiando a organización: ${newOrg}`)
  emit('organization-changed', newOrg)
}

const refreshOrgData = async () => {
  isRefreshing.value = true
  try {
    console.log(`Actualizando datos para: ${selectedOrg.value}`)
    emit('refresh-requested', selectedOrg.value)
    
    // Simular delay de actualización
    await new Promise(resolve => setTimeout(resolve, 1000))
    
  } catch (error) {
    console.error('Error actualizando datos:', error)
  } finally {
    isRefreshing.value = false
  }
}

const showOrgDetails = () => {
  const org = organizationConfig[selectedOrg.value]
  if (org) {
    // Aquí podrías abrir un modal o navegar a una página de detalles
    console.log('Detalles de la organización:', org)
  }
}

// Watch para cambios externos en currentOrg
watch(() => props.currentOrg, (newOrg) => {
  if (newOrg && newOrg !== selectedOrg.value) {
    selectedOrg.value = newOrg
  }
})

// Exponer métodos para uso externo
defineExpose({
  selectedOrg,
  refreshOrgData,
  showOrgDetails
})
</script>

<style scoped>
.org-selector-container {
  margin: 16px 0;
}

.org-selector-card {
  background: linear-gradient(135deg, #f8f9fa, #e9ecef) !important;
  border: 1px solid #dee2e6 !important;
  border-radius: 16px !important;
  transition: all 0.3s ease;
}

.org-selector-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15) !important;
}

.org-selector-title {
  background: linear-gradient(135deg, #28a745, #20c997) !important;
  color: white !important;
  border-radius: 16px 16px 0 0 !important;
  font-weight: 600 !important;
  font-size: 16px !important;
  padding: 16px 20px !important;
}

.org-selector-content {
  padding: 20px !important;
}

.org-select-wrapper {
  max-width: 400px;
}

.org-select {
  background: white !important;
}

.org-info {
  text-align: center;
}

.org-chip {
  font-weight: 600 !important;
  font-size: 16px !important;
  padding: 12px 20px !important;
  transition: all 0.3s ease;
}

.org-chip:hover {
  transform: scale(1.05);
}

.org-description {
  max-width: 300px;
  margin: 0 auto;
  line-height: 1.4;
}

.org-stats {
  background: rgba(255, 255, 255, 0.7) !important;
  border-radius: 12px !important;
  padding: 16px !important;
  margin-top: 16px !important;
}

.stat-item {
  text-align: center;
  padding: 8px;
}

.stat-value {
  font-size: 24px !important;
  font-weight: 700 !important;
  color: #28a745 !important;
  line-height: 1;
}

.stat-label {
  font-size: 12px !important;
  color: #6c757d !important;
  margin-top: 4px !important;
  text-transform: uppercase !important;
  letter-spacing: 0.5px !important;
}

.org-selector-actions {
  padding: 16px 20px !important;
  background: rgba(248, 249, 250, 0.8) !important;
  border-top: 1px solid #dee2e6 !important;
}

/* Responsive */
@media (max-width: 768px) {
  .org-selector-content {
    padding: 16px !important;
  }
  
  .org-select-wrapper {
    max-width: 100%;
  }
  
  .org-chip {
    font-size: 14px !important;
    padding: 10px 16px !important;
  }
  
  .stat-value {
    font-size: 20px !important;
  }
}

@media (max-width: 480px) {
  .org-selector-title {
    font-size: 14px !important;
    padding: 12px 16px !important;
  }
  
  .org-selector-content {
    padding: 12px !important;
  }
  
  .org-stats {
    padding: 12px !important;
  }
}
</style>
