<template>
  <v-card class="date-range-card" elevation="3">
    <v-card-title class="text-h6 pa-4 pb-2">
      <div class="d-flex align-center">
        <v-icon start size="20" color="success" class="mr-2">mdi-calendar-range</v-icon>
        Filtro de Rango de Fechas
        <v-chip 
          color="info" 
          variant="tonal" 
          size="small" 
          class="ml-3"
          @click="showLimitsInfo = !showLimitsInfo"
        >
          <v-icon start size="16">mdi-information</v-icon>
          Límites API
        </v-chip>
      </div>
    </v-card-title>

    <!-- Información sobre límites de la API -->
    <client-only>
      <v-expand-transition>
        <div v-show="showLimitsInfo" class="px-4 mb-4">
          <v-alert 
            type="info" 
            variant="tonal" 
            density="compact"
            class="mb-2"
          >
            <template #title>
              <strong>Límites de GitHub Copilot API:</strong>
            </template>
            <ul class="mt-2 mb-0">
              <li>📅 <strong>Máximo:</strong> 100 días de rango histórico</li>
              <li>🚫 <strong>No permite:</strong> Fechas futuras</li>
              <li>📊 <strong>Recomendado:</strong> Últimos 28 días</li>
              <li>⚠️ <strong>Histórico:</strong> Datos limitados antes de 2022</li>
            </ul>
          </v-alert>
        </div>
      </v-expand-transition>
    </client-only>

    <v-card-text class="pa-4 pt-0">
      <v-row align="end" class="g-0">
        <v-col cols="12" sm="3" class="pa-2">
          <v-text-field
            v-model="fromDate"
            label="Fecha Desde"
            type="date"
            variant="outlined"
            density="compact"
            :min="getMinAllowedDate()"
            :max="getMaxAllowedDate()"
            @update:model-value="updateDateRange"
            :error="!!validationErrors.from"
            :error-messages="validationErrors.from"
            hide-details="auto"
          />
        </v-col>
        <v-col cols="12" sm="3" class="pa-2">
          <v-text-field
            v-model="toDate"
            label="Fecha Hasta"
            type="date"
            variant="outlined"
            density="compact"
            :min="fromDate"
            :max="getMaxAllowedDate()"
            @update:model-value="updateDateRange"
            :error="!!validationErrors.to"
            :error-messages="validationErrors.to"
            hide-details="auto"
          />
        </v-col>
        <v-col cols="12" sm="2" class="pa-2 d-flex align-center">
          <v-checkbox
            v-model="excludeHolidays"
            label="Excluir feriados"
            density="compact"
            hide-details
          />
        </v-col>
        <v-col cols="12" sm="4" class="pa-2 d-flex align-center justify-center">
          <div class="button-group">
            <v-btn
              class="hdi-btn-secondary mr-2 mb-2"
              size="small"
              @click="resetToDefault"
            >
              Últimos 28 Días
            </v-btn>
            <v-btn
              class="hdi-btn-primary mr-2 mb-2"
              size="small"
              @click="setMaxRange"
            >
              Máximo (100 días)
            </v-btn>
            <v-btn
              class="hdi-btn-primary mb-2"
              size="small"
              :loading="loading"
              :disabled="!isDateRangeValid"
              @click="applyDateRange"
            >
              Aplicar
            </v-btn>
          </div>
        </v-col>
      </v-row>
    </v-card-text>

    <!-- Mensajes de validación -->
    <client-only>
      <v-expand-transition>
        <div v-show="validationResult && (!validationResult.isValid || validationResult.warnings.length > 0)">
          <v-alert 
            :type="validationResult?.isValid ? 'warning' : 'error'" 
            variant="tonal" 
            density="compact"
            class="mt-3"
          >
            <template #title>
              <strong>{{ validationResult?.isValid ? 'Advertencias' : 'Errores de validación' }}</strong>
            </template>
            <div v-if="validationResult && !validationResult.isValid">
              <div v-for="error in validationResult.errors" :key="error" class="mb-1">
                ❌ {{ error }}
              </div>
            </div>
            <div v-if="validationResult && validationResult.warnings.length > 0">
              <div v-for="warning in validationResult.warnings" :key="warning" class="mb-1">
                ⚠️ {{ warning }}
              </div>
            </div>
            <div v-if="validationResult && validationResult.adjustedDates" class="mt-2">
              <v-btn 
                size="small" 
                color="primary" 
                variant="outlined"
                @click="applyAdjustedDates"
              >
                Aplicar fechas ajustadas
              </v-btn>
            </div>
          </v-alert>
        </div>
      </v-expand-transition>
    </client-only>
    
    <v-card-text class="pt-2">
      <span class="text-caption text-medium-emphasis">
        {{ dateRangeText }}
      </span>
      <div v-if="daysDifference > 0" class="mt-1">
        <v-chip 
          :color="getDaysChipColor()" 
          variant="tonal" 
          size="small"
        >
          {{ daysDifference }} días
        </v-chip>
        <span class="text-caption text-medium-emphasis ml-2">
          {{ getDaysStatusText() }}
        </span>
      </div>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { 
  validateGitHubCopilotDateRange, 
  getDefaultDateRange, 
  getMaxAllowedDateRange,
  type DateValidationResult,
  type DateRange,
  GITHUB_COPILOT_LIMITS
} from '../utils/dateValidation'
import { useHydration } from '../composables/useHydration'

interface Props {
  loading?: boolean
}

interface Emits {
  (e: 'date-range-changed', value: { 
    since?: string; 
    until?: string; 
    description: string;
    excludeHolidays?: boolean;
  }): void
}

withDefaults(defineProps<Props>(), {
  loading: false
})

const emit = defineEmits<Emits>()

// Composable de hidratación
const { isHydrated, isClient } = useHydration()

// Estado del componente
const showLimitsInfo = ref(false)
const fromDate = ref('')
const toDate = ref('')
const excludeHolidays = ref(false)
const validationResult = ref<DateValidationResult | null>(null)
const validationErrors = ref({ from: '', to: '' })

// Calcular fechas por defecto solo en el cliente
onMounted(() => {
  if (isClient.value) {
    const defaultRange = getDefaultDateRange()
    fromDate.value = defaultRange.since
    toDate.value = defaultRange.until
    validateCurrentDateRange()
    applyDateRange()
  }
})

// Computed properties
const daysDifference = computed(() => {
  if (!fromDate.value || !toDate.value) return 0
  
  const from = new Date(fromDate.value + 'T00:00:00.000Z')
  const to = new Date(toDate.value + 'T00:00:00.000Z')
  const diffTime = to.getTime() - from.getTime()
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1
})

const isDateRangeValid = computed(() => {
  return validationResult.value?.isValid ?? false
})

const dateRangeText = computed(() => {
  if (!fromDate.value || !toDate.value) {
    return 'Selecciona un rango de fechas'
  }
  
  const from = new Date(fromDate.value + 'T00:00:00.000Z')
  const to = new Date(toDate.value + 'T00:00:00.000Z')
  const withoutHolidays = excludeHolidays.value ? ' (excluyendo feriados)' : ''

  if (daysDifference.value === 1) {
    return `Para ${formatDateForDisplay(from)}${withoutHolidays}`
  } else if (daysDifference.value <= 28 && isLast28Days()) {
    return `Durante los últimos 28 días${withoutHolidays}`
  } else {
    return `Desde ${formatDateForDisplay(from)} hasta ${formatDateForDisplay(to)} (${daysDifference.value} días)${withoutHolidays}`
  }
})

// Funciones de utilidad
function formatDateForDisplay(date: Date): string {
  const day = date.getUTCDate()
  const month = date.getUTCMonth() + 1
  const year = date.getUTCFullYear()
  return `${month}/${day}/${year}`
}

function isLast28Days(): boolean {
  if (!fromDate.value || !toDate.value) return false
  
  const today = new Date()
  const expectedFromDate = new Date(today.getTime() - 27 * 24 * 60 * 60 * 1000)
  
  const from = new Date(fromDate.value + 'T00:00:00.000Z')
  const to = new Date(toDate.value + 'T00:00:00.000Z')
  
  return (
    from.toDateString() === expectedFromDate.toDateString() &&
    to.toDateString() === today.toDateString()
  )
}

function getMinAllowedDate(): string {
  const today = new Date()
  const minDate = new Date(today.getTime() - GITHUB_COPILOT_LIMITS.MAX_HISTORICAL_DAYS * 24 * 60 * 60 * 1000)
  return minDate.toISOString().split('T')[0] || ''
}

function getMaxAllowedDate(): string {
  const today = new Date()
  return today.toISOString().split('T')[0] || ''
}

function getDaysChipColor(): string {
  if (daysDifference.value <= 28) return 'success'
  if (daysDifference.value <= 60) return 'warning'
  if (daysDifference.value <= 100) return 'info'
  return 'error'
}

function getDaysStatusText(): string {
  if (daysDifference.value <= 28) return 'Rango óptimo'
  if (daysDifference.value <= 60) return 'Rango aceptable'
  if (daysDifference.value <= 100) return 'Rango máximo permitido'
  return 'Rango excede límites'
}

// Funciones de acción
function updateDateRange() {
  validateCurrentDateRange()
}

function validateCurrentDateRange() {
  if (!fromDate.value || !toDate.value) {
    validationResult.value = null
    validationErrors.value = { from: '', to: '' }
    return
  }

  // Validar con modo estricto para mostrar errores
  validationResult.value = validateGitHubCopilotDateRange(
    fromDate.value, 
    toDate.value, 
    { strictMode: true }
  )

  // Limpiar errores previos
  validationErrors.value = { from: '', to: '' }

  // Mostrar errores específicos en los campos
  if (!validationResult.value.isValid) {
    validationResult.value.errors.forEach(error => {
      if (error.includes('inicio')) {
        validationErrors.value.from = error
      } else if (error.includes('fin') || error.includes('futuras')) {
        validationErrors.value.to = error
      }
    })
  }
}

function resetToDefault() {
  const defaultRange = getDefaultDateRange()
  fromDate.value = defaultRange.since
  toDate.value = defaultRange.until
  excludeHolidays.value = false
  validateCurrentDateRange()
}

function setMaxRange() {
  const maxRange = getMaxAllowedDateRange()
  fromDate.value = maxRange.since
  toDate.value = maxRange.until
  validateCurrentDateRange()
}

function applyAdjustedDates() {
  if (validationResult.value?.adjustedDates) {
    fromDate.value = validationResult.value.adjustedDates.since
    toDate.value = validationResult.value.adjustedDates.until
    validateCurrentDateRange()
  }
}

function applyDateRange() {
  if (!fromDate.value || !toDate.value) {
    return
  }
  
  // Validar antes de aplicar
  const validation = validateGitHubCopilotDateRange(
    fromDate.value, 
    toDate.value, 
    { strictMode: false } // Modo no estricto para permitir ajustes
  )

  if (!validation.isValid) {
    validationResult.value = validation
    return
  }

  // Aplicar fechas ajustadas si es necesario
  if (validation.adjustedDates) {
    fromDate.value = validation.adjustedDates.since
    toDate.value = validation.adjustedDates.until
  }

  // Emitir el cambio
  emit('date-range-changed', {
    since: fromDate.value,
    until: toDate.value,
    description: dateRangeText.value,
    excludeHolidays: excludeHolidays.value,
  })
}

// Watchers
watch([fromDate, toDate], () => {
  validateCurrentDateRange()
})

// Inicialización
onMounted(() => {
  validateCurrentDateRange()
  applyDateRange()
})
</script>

<style scoped>
/* Estilos del contenedor principal */
.date-range-card {
  margin: 16px 0;
  border-radius: 12px;
  border: 2px solid #dee2e6;
  background: linear-gradient(135deg, #f8f9fa, #e9ecef);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* Estilos para el fallback del servidor */
.date-range-card-server {
  margin: 16px 0;
  border-radius: 12px;
  border: 2px solid #dee2e6;
  background: linear-gradient(135deg, #f8f9fa, #e9ecef);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 16px;
}

.date-range-card-server .text-h6 {
  font-size: 1.25rem;
  font-weight: 500;
  margin-bottom: 16px;
}

.date-range-card-server .d-flex {
  display: flex;
  align-items: center;
}

.date-range-card-server .mr-2 {
  margin-right: 8px;
}

.date-range-card-server .ml-3 {
  margin-left: 12px;
}

.date-range-card-server .chip-info {
  background: #e3f2fd;
  color: #1976d2;
  padding: 4px 8px;
  border-radius: 16px;
  font-size: 0.875rem;
  font-weight: 500;
}

.date-range-card-server .row {
  display: flex;
  flex-wrap: wrap;
  margin: 0 -8px;
}

.date-range-card-server .col-3,
.date-range-card-server .col-2,
.date-range-card-server .col-4 {
  padding: 0 8px;
}

.date-range-card-server .col-3 {
  flex: 0 0 25%;
  max-width: 25%;
}

.date-range-card-server .col-2 {
  flex: 0 0 16.666667%;
  max-width: 16.666667%;
}

.date-range-card-server .col-4 {
  flex: 0 0 33.333333%;
  max-width: 33.333333%;
}

.date-range-card-server .pa-2 {
  padding: 8px;
}

.date-range-card-server .text-center {
  text-align: center;
}

.date-range-card-server .input-placeholder,
.date-range-card-server .checkbox-placeholder,
.date-range-card-server .button-placeholder {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 12px;
  text-align: center;
  color: #6c757d;
  font-size: 0.875rem;
  min-height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Estilos para los botones */
.hdi-btn-primary {
  background: linear-gradient(135deg, #28a745, #20c997) !important;
  color: white !important;
  border: none !important;
}

.hdi-btn-secondary {
  background: linear-gradient(135deg, #6c757d, #495057) !important;
  color: white !important;
  border: none !important;
}

.hdi-btn-primary:hover,
.hdi-btn-secondary:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.hdi-btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

/* Estilos para el grupo de botones */
.button-group {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 8px;
}

/* Responsive para los botones */
@media (max-width: 768px) {
  .button-group {
    flex-direction: column;
    align-items: center;
  }
  
  .button-group .v-btn {
    margin: 4px 0 !important;
    min-width: 200px;
  }
  
  .date-range-card-server .col-3,
  .date-range-card-server .col-2,
  .date-range-card-server .col-4 {
    flex: 0 0 100%;
    max-width: 100%;
    margin-bottom: 8px;
  }
}

@media (max-width: 480px) {
  .button-group .v-btn {
    min-width: 180px;
    font-size: 14px;
  }
}
</style>