<template>
  <div>
    <!-- Toolbar: Solo visible cuando el usuario está autenticado o no se requiere autenticación -->
    <AuthState>
      <template #default="{ loggedIn }">
        <v-toolbar v-if="!signInRequired || (signInRequired && loggedIn)" class="bg-hdi-universal-green" elevation="4">
      

             <v-toolbar-title class="toolbar-title">
         <div class="d-flex align-center">
           <div class="hdi-logo-container mr-3">
             <img src="/assets/hdi.png" alt="HDI Logo" class="hdi-logo-svg" />
           </div>
           <div class="title-content">
             <div class="main-title">Panel de Métricas de Copilot</div>
             <div class="subtitle">Organización: {{ displayName }}</div>
           </div>
         </div>
       </v-toolbar-title>
      <h2 class="error-message"> {{ mockedDataMessage }} </h2>
      <v-spacer />

      <!-- GitHub Authentication State -->
      <AuthState>
        <template #default="{ loggedIn, user }">
          <div v-show="loggedIn" class="user-info">
            <v-menu>
              <template #activator="{ props }">
                <v-chip 
                  color="success" 
                  variant="elevated" 
                  class="user-chip"
                  v-bind="props"
                  clickable
                >
                  <v-avatar size="28" class="user-avatar">
                    <v-img :alt="user?.name" :src="user?.avatarUrl" />
                  </v-avatar>
                  <span class="ml-2 user-name">{{ user?.name }}</span>
                  <v-icon size="16" class="ml-1">mdi-chevron-down</v-icon>
                </v-chip>
              </template>
              <v-list>
                <v-list-item>
                  <template #prepend>
                    <v-avatar size="32">
                      <v-img :alt="user?.name" :src="user?.avatarUrl" />
                    </v-avatar>
                  </template>
                  <v-list-item-title>{{ user?.name }}</v-list-item-title>
                  <v-list-item-subtitle>Usuario autenticado</v-list-item-subtitle>
                </v-list-item>
                <v-divider />
                <v-list-item @click="logout">
                  <template #prepend>
                    <v-icon color="error">mdi-logout</v-icon>
                  </template>
                  <v-list-item-title>Cerrar Sesión</v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>
          </div>
        </template>
      </AuthState>

      <template #extension>
        <v-tabs 
          v-model="tab" 
          align-tabs="title"
          class="custom-tabs"
          color="success"
          height="60"
          background-color="rgba(255, 255, 255, 0.1)"
        >
          <v-tab 
            v-for="item in tabItems" 
            :key="item" 
            :value="item"
            class="custom-tab"
            :ripple="false"
          >
            <div class="tab-content">
              <v-icon class="tab-icon mr-2">{{ getTabIcon(item) }}</v-icon>
              <span class="tab-text">{{ item }}</span>
            </div>
          </v-tab>
        </v-tabs>
      </template>
    </v-toolbar>
  </template>
</AuthState>

    <!-- Organization Selector: Solo visible cuando el usuario está autenticado -->
    <AuthState>
      <template #default="{ loggedIn }">
        <div v-if="!signInRequired || (signInRequired && loggedIn)" class="org-selector-wrapper">
       <div class="org-selector-toggle" @click="toggleOrgSelector">
         <v-icon 
           :class="['toggle-icon', { 'rotated': !showOrgSelector }]"
           color="success"
           size="24"
         >
           mdi-chevron-up
         </v-icon>
         <span class="toggle-text">
           {{ showOrgSelector ? 'Ocultar Selector' : 'Mostrar Selector de Organización' }}
         </span>
       </div>
       
       <v-slide-y-transition>
         <div v-show="showOrgSelector">
           <OrganizationSelector 
             :organizations="['hdicl', 'HDISeguros-cl']"
             :current-org="currentOrg"
             @organization-changed="handleOrganizationChange"
             @refresh-requested="handleRefreshRequested"
           />
         </div>
       </v-slide-y-transition>
        </div>
      </template>
    </AuthState>

    <!-- Date Range Selector - Hidden for seats tab -->
         <!-- Selector de rango de fechas: Solo visible cuando el usuario está autenticado -->
         <AuthState>
           <template #default="{ loggedIn }">
             <DateRangeSelector 
               v-show="tab !== 'análisis de asientos' && (!signInRequired || (signInRequired && loggedIn))" 
               :loading="isLoading"
               @date-range-changed="handleDateRangeChange" />
           </template>
         </AuthState>

    <!-- Organization info for seats tab: Solo visible cuando el usuario está autenticado -->
         <AuthState>
           <template #default="{ loggedIn }">
             <div v-if="tab === 'análisis de asientos' && (!signInRequired || (signInRequired && loggedIn))" class="organization-info">
      <v-card flat class="pa-3 mb-2">
        <div class="text-body-2 text-center">
          Displaying data for organization: <strong>{{ currentOrg }}</strong>
        </div>
      </v-card>
             </div>
           </template>
         </AuthState>

    <!-- API Error Message -->
    <div v-show="apiError && !signInRequired" class="error-message" v-text="apiError" />
    
    <!-- Authentication Error Message -->
    <v-alert 
      v-if="authError" 
      type="error" 
      variant="tonal" 
      class="ma-4"
      closable
      @click:close="authError = null"
    >
      <v-alert-title>Error de Autenticación</v-alert-title>
      {{ authError }}
    </v-alert>
    <AuthState>
      <template #default="{ loggedIn }">
        <!-- Sección de login: Solo visible para usuarios NO autenticados -->
        <div v-if="!loggedIn && signInRequired" class="github-login-container">
          <v-card class="login-card" elevation="8">
            <!-- Header con gradiente -->
            <v-card-title class="login-header">
              <div class="login-icon-container">
                <v-icon color="white" size="64" class="login-icon">mdi-shield-check</v-icon>
              </div>
              <h2 class="login-title">Acceso Seguro</h2>
              <p class="login-subtitle">Panel de Métricas HDI</p>
            </v-card-title>
            
            <v-card-text class="login-content">
              <div class="security-info">
                <v-icon color="success" size="20" class="mr-2">mdi-lock-check</v-icon>
                <span class="text-body-2">Conexión segura y encriptada</span>
              </div>
              
              <p class="login-description">
                Para acceder a las métricas de GitHub Copilot de HDI, necesitas autenticarte con tu cuenta de GitHub.
              </p>
              
              <div class="benefits-list">
                <div class="benefit-item">
                  <v-icon color="primary" size="16">mdi-check-circle</v-icon>
                  <span>Acceso a métricas en tiempo real</span>
                </div>
                <div class="benefit-item">
                  <v-icon color="primary" size="16">mdi-check-circle</v-icon>
                  <span>Datos seguros y privados</span>
                </div>
                <div class="benefit-item">
                  <v-icon color="primary" size="16">mdi-check-circle</v-icon>
                  <span>Sesión automática</span>
                </div>
              </div>
              
              <NuxtLink to="/auth/github" external class="login-link">
                <v-btn 
                  color="primary" 
                  size="x-large" 
                  variant="elevated"
                  class="github-login-button"
                  block
                >
                  <v-icon left size="24">mdi-github</v-icon>
                  Iniciar Sesión con GitHub
                </v-btn>
              </NuxtLink>
              
              <div class="trust-indicators">
                <v-chip size="small" color="success" variant="tonal">
                  <v-icon start size="12">mdi-shield-check</v-icon>
                  SSL Seguro
                </v-chip>
                <v-chip size="small" color="info" variant="tonal">
                  <v-icon start size="12">mdi-github</v-icon>
                  OAuth 2.0
                </v-chip>
              </div>
            </v-card-text>
          </v-card>
        </div>
      </template>
      <template #placeholder>
        <!-- Estado de carga: Solo visible durante la verificación de autenticación -->
        <div v-if="signInRequired" class="github-login-container">
          <v-card class="login-card loading-card" elevation="8">
            <v-card-title class="login-header">
              <div class="login-icon-container">
                <v-progress-circular 
                  indeterminate 
                  color="white" 
                  size="64" 
                  width="4"
                  class="login-icon"
                />
              </div>
              <h2 class="login-title">Verificando Acceso</h2>
              <p class="login-subtitle">Validando credenciales...</p>
            </v-card-title>
            
            <v-card-text class="login-content text-center">
              <div class="loading-steps">
                <div class="loading-step active">
                  <v-icon color="primary" size="16">mdi-check-circle</v-icon>
                  <span>Conectando con GitHub</span>
                </div>
                <div class="loading-step">
                  <v-progress-circular indeterminate size="16" width="2" color="primary" />
                  <span>Verificando permisos</span>
                </div>
                <div class="loading-step">
                  <v-icon color="grey" size="16">mdi-circle-outline</v-icon>
                  <span>Iniciando sesión</span>
                </div>
              </div>
            </v-card-text>
          </v-card>
        </div>
        
        <!-- Sección de contenido: Solo visible para usuarios autenticados -->
        <div v-else-if="loggedIn" class="authenticated-content">
          <!-- El contenido principal de la aplicación se muestra aquí cuando el usuario está autenticado -->
        </div>
      </template>
    </AuthState>


    <!-- Contenido principal: Solo visible cuando el usuario está autenticado o no se requiere autenticación -->
    <AuthState>
      <template #default="{ loggedIn }">
        <div v-show="!apiError && (!signInRequired || (signInRequired && loggedIn))">
             <v-progress-linear v-show="!metricsReady" indeterminate class="bg-hdi-universal-green" />
             <v-window v-show="(metricsReady && metrics.length) || (seatsReady && tab === 'análisis de asientos')" v-model="tab">
                 <v-window-item v-for="item in tabItems" :key="item" :value="item">
           <v-card flat>
             <MetricsViewer v-if="item === getDisplayTabName(itemName)" :metrics="metrics" :date-range-description="dateRangeDescription" />
             <TeamsComponent v-if="item === 'teams'" :date-range-description="dateRangeDescription" :date-range="dateRange" />
             <BreakdownComponent
 v-if="item === 'lenguajes'" :metrics="metrics" :breakdown-key="'language'"
               :date-range-description="dateRangeDescription" />
             <BreakdownComponent
 v-if="item === 'editores'" :metrics="metrics" :breakdown-key="'editor'"
               :date-range-description="dateRangeDescription" />
             <CopilotChatViewer
 v-if="item === 'chat copilot'" :metrics="metrics"
               :date-range-description="dateRangeDescription" />
             <AgentModeViewer v-if="item === 'github.com'" :original-metrics="originalMetrics" :date-range="dateRange" :date-range-description="dateRangeDescription" />
             <SeatsAnalysisViewer v-if="item === 'análisis de asientos'" :seats="seats" />
             <ApiResponse
 v-if="item === 'respuesta api'" :metrics="metrics" :original-metrics="originalMetrics"
               :seats="seats" />
           </v-card>
         </v-window-item>
                 <v-alert
           v-show="(metricsReady && metrics.length == 0 && tab !== 'análisis de asientos') || (seatsReady && seats.length == 0 && tab === 'análisis de asientos')"
           density="compact" text="No hay datos disponibles para mostrar" title="Sin datos" type="warning" />
      </v-window>
        </div>
      </template>
    </AuthState>

  </div>
</template>
<script lang='ts'>
import type { Metrics } from '@/model/Metrics';
import type { CopilotMetrics } from '@/model/Copilot_Metrics';
import type { MetricsApiResponse } from '@/types/metricsApiResponse';
import type { Seat } from "@/model/Seat";
import type { H3Error } from 'h3'

//Components
import MetricsViewer from './MetricsViewer.vue'
import BreakdownComponent from './BreakdownComponent.vue'
import CopilotChatViewer from './CopilotChatViewer.vue'
import SeatsAnalysisViewer from './SeatsAnalysisViewer.vue'
import TeamsComponent from './TeamsComponent.vue'
import ApiResponse from './ApiResponse.vue'
import AgentModeViewer from './AgentModeViewer.vue'
import DateRangeSelector from './DateRangeSelector.vue'
import OrganizationSelector from './OrganizationSelector.vue'
import { Options } from '@/model/Options';
import { useRoute } from 'vue-router';
import { useOrganizations } from '../composables/useOrganizations';
import { useUserSession } from '../composables/useUserSession';

export default defineNuxtComponent({
  name: 'MainComponent',
  components: {
    MetricsViewer,
    BreakdownComponent,
    CopilotChatViewer,
    SeatsAnalysisViewer,
    TeamsComponent,
    ApiResponse,
    AgentModeViewer,
    DateRangeSelector,
    OrganizationSelector
  },
  methods: {
    logout() {
      const { clear } = useUserSession()
      this.metrics = [];
      this.seats = [];
      clear();
    },
         getDisplayTabName(itemName: string): string {
       // Transform scope names to display names for tabs
       switch (itemName) {
         case 'team-organization':
         case 'team-enterprise':
           return 'team';
         case 'organization':
         case 'enterprise':
           return itemName;
         default:
           return itemName;
       }
     },

     getTabIcon(tabName: string): string {
       // Return appropriate icons for each tab
       switch (tabName) {
         case 'lenguajes':
           return 'mdi-language-typescript';
         case 'editores':
           return 'mdi-code-braces';
         case 'chat copilot':
           return 'mdi-robot';
         case 'github.com':
           return 'mdi-github';
         case 'análisis de asientos':
           return 'mdi-account-group';
         case 'respuesta api':
           return 'mdi-api';
         case 'teams':
           return 'mdi-account-multiple';
         default:
           return 'mdi-tab';
       }
     },

     toggleOrgSelector() {
       this.showOrgSelector = !this.showOrgSelector;
     },
    async handleDateRangeChange(newDateRange: { 
      since?: string; 
      until?: string; 
      description: string;
      excludeHolidays?: boolean;
    }) {
      this.dateRangeDescription = newDateRange.description;
      this.dateRange = {
        since: newDateRange.since,
        until: newDateRange.until
      };

      // Store holiday options
      this.holidayOptions = {
        excludeHolidays: newDateRange.excludeHolidays ?? false,
      };

      await this.fetchMetrics();
    },

    handleOrganizationChange(newOrg: string) {
      console.log(`Cambiando a organización: ${newOrg}`);
      
      // Recargar datos para la nueva organización
      this.refreshDataForOrganization(newOrg);
    },

    handleRefreshRequested(org: string) {
      console.log(`Solicitando actualización para: ${org}`);
      this.refreshDataForOrganization(org);
    },

    async refreshDataForOrganization(org: string) {
      try {
        console.log(`Recargando datos para: ${org}`);
        
        // Actualizar la organización actual usando el composable
        this.changeOrganization(org);
        
        // Limpiar datos anteriores
        this.metrics = [];
        this.originalMetrics = [];
        this.seats = [];
        this.metricsReady = false;
        this.seatsReady = false;
        
        // Recargar métricas para la nueva organización
        if (this.dateRange.since && this.dateRange.until) {
          await this.fetchMetrics();
        }
        
        // Recargar seats para la nueva organización
        await this.fetchSeatsForOrganization(org);
        
      } catch (error) {
        console.error(`Error recargando datos para ${org}:`, error);
      }
    },

    async fetchSeatsForOrganization(org: string) {
      try {
        console.log(`Recargando seats para: ${org}`);
        
        // Construir URL con parámetros de organización
        const params = new URLSearchParams();
        if (this.currentOrg) {
          params.append('githubOrg', this.currentOrg);
        }
        
        const apiUrl = `/api/seats?${params.toString()}`;
        const response = await $fetch(apiUrl) as Seat[];
        
        this.seats = response || [];
        this.seatsReady = true;
        
      } catch (error) {
        console.error(`Error recargando seats para ${org}:`, error);
        if (error && typeof error === 'object' && 'statusCode' in error) {
          this.processError(error as H3Error);
        } else {
          console.error('Error desconocido:', error);
        }
      }
    },
    async fetchMetrics() {
      if (this.signInRequired || !this.dateRange || !this.dateRange.since || !this.dateRange.until || this.isLoading) {
        return;
      }
      const config = useRuntimeConfig();

      this.isLoading = true;
      // Clear previous API errors when making a new request
      this.apiError = undefined;

      try {
        const options = Options.fromRoute(this.route, this.dateRange.since, this.dateRange.until);
        
        // Add holiday options if they're set
        if (this.holidayOptions && typeof this.holidayOptions.excludeHolidays === 'boolean') {
          options.excludeHolidays = this.holidayOptions.excludeHolidays;
        }
        
        const params = options.toParams();
        
        // Add organization parameter if selected
        if (this.currentOrg) {
          params.githubOrg = this.currentOrg;
        }

        const queryString = new URLSearchParams(params).toString();
        const apiUrl = queryString ? `/api/metrics?${queryString}` : '/api/metrics';

        const response = await $fetch(apiUrl) as MetricsApiResponse;

        this.metrics = response.metrics || [];
        this.originalMetrics = response.usage || [];
        this.metricsReady = true;

        if (config.public.scope && config.public.scope.includes('team') && this.metrics.length === 0 && !this.apiError) {
          this.apiError = 'No data returned from API - check if the team exists and has any activity and at least 5 active members';
        }

      } catch (error: any) {
        if (error && typeof error === 'object' && 'statusCode' in error) {
          this.processError(error as H3Error);
        } else {
          console.error('Error desconocido:', error);
        }
      } finally {
        this.isLoading = false;
      }
    },
    processError(error: H3Error) {
      console.error(error || 'No data returned from API');
      // Check the status code of the error response
      if (error && error.statusCode) {
        switch (error.statusCode) {
          case 401:
            this.apiError = '401 Unauthorized access returned by GitHub API - check if your token in the .env (for local runs). Check PAT token and GitHub permissions.';
            break;
          case 404:
            this.apiError = `404 Not Found - is the ${this.config?.public?.scope || ''} org:"${this.config?.public?.githubOrg || ''}" ent:"${this.config?.public?.githubEnt || ''}" team:"${this.config?.public?.githubTeam}" correct? ${error.message}`;
            break;
          case 422:
            this.apiError = `422 Unprocessable Entity - Is the Copilot Metrics API enabled for the Org/Ent? When changing filters, try adjusting the "from" date.  ${error.message}`;
            break;
          case 500:
            this.apiError = `500 Internal Server Error - most likely a bug in the app. Error: ${error.message}`;
            break;
          default:
            this.apiError = `${error.statusCode} Error: ${error.message}`;
            break;
        }
      }
    }
  },

           data() {
      return {
        tabItems: ['lenguajes', 'editores', 'chat copilot', 'github.com', 'análisis de asientos', 'respuesta api'],
        tab: null,
        dateRangeDescription: 'Durante los últimos 28 días',
        dateRange: { since: undefined as string | undefined, until: undefined as string | undefined },
        isLoading: false,
        metricsReady: false,
        metrics: [] as Metrics[],
        originalMetrics: [] as CopilotMetrics[],
        seatsReady: false,
        seats: [] as Seat[],
        apiError: undefined as string | undefined,
        config: null as ReturnType<typeof useRuntimeConfig> | null,
        holidayOptions: {
          excludeHolidays: false,
        },
        showOrgSelector: false
      }
    },
  created() {
    this.tabItems.unshift(this.getDisplayTabName(this.itemName));
    
    // Add teams tab for organization and enterprise scopes to allow team comparison
    if (this.itemName === 'organization' || this.itemName === 'enterprise') {
      this.tabItems.splice(1, 0, 'teams'); // Insert after the first tab
    }
    
    this.config = useRuntimeConfig();
  },
  async mounted() {
    // Load initial data
    try {

      await this.fetchMetrics();

      const { data: seatsData, error: seatsError, execute: executeSeats } = this.seatsFetch;

      await executeSeats();

      if (seatsError.value) {
          this.processError(seatsError.value as H3Error);
        } else {
          this.seats = (seatsData.value as Seat[]) || [];
          this.seatsReady = true;
        }

    } catch (error) {
      console.error('Error loading initial data:', error);
    }
  },
  async setup() {
    const { loggedIn, user } = useUserSession()
    const config = useRuntimeConfig();
    const { currentOrg, changeOrganization } = useOrganizations();
    const showLogoutButton = computed(() => config.public.usingGithubAuth && loggedIn.value);
    
    const mockedDataMessage = computed(() => config.public.isDataMocked ? 'Using mock data - see README if unintended' : '');
    const itemName = computed(() => config.public.scope);
    const githubInfo = getDisplayName(config.public)
    const displayName = computed(() => githubInfo);
    const isLoading = ref(false);
    const route = ref(useRoute());
    const authError = ref<string | null>(null);

    const signInRequired = computed(() => {
      return config.public.usingGithubAuth && !loggedIn.value;
    });

    // Verificar si hay errores de autenticación en la URL
    const checkAuthError = () => {
      const query = route.value.query;
      if (query.error) {
        authError.value = decodeURIComponent(query.error as string);
      }
    };

    // Ejecutar verificación al montar el componente
    checkAuthError();

    const seatsFetch = useFetch('/api/seats', {
      server: true,
      immediate: !signInRequired.value,
      query: computed(() => {
        const options = Options.fromRoute(route.value);
        const params = options.toParams();
        // Agregar organización actual a los parámetros
        if (currentOrg.value) {
          params.githubOrg = currentOrg.value;
        }
        return params;
      })
    });

    return {
      mockedDataMessage,
      itemName,
      displayName,
      signInRequired,
      user,
      showLogoutButton,
      authError,
      seatsFetch,
      isLoading,
      route,
      currentOrg,
      changeOrganization,
    };
  },
})
</script>

<style scoped>
.toolbar-title {
  white-space: nowrap;
  overflow: visible;
  text-overflow: clip;

}

.error-message {
  color: red;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-chip {
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s ease;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.user-chip:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.user-avatar {
  border: 2px solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
}

.user-chip:hover .user-avatar {
  border-color: rgba(255, 255, 255, 0.6);
  transform: scale(1.05);
}

.user-name {
  font-weight: 600;
  font-size: 0.9rem;
}

.github-login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
  overflow: hidden;
}

.github-login-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="50" cy="50" r="1" fill="rgba(255,255,255,0.1)"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
  opacity: 0.3;
  pointer-events: none;
}

.login-card {
  max-width: 450px;
  width: 100%;
  margin: 0 auto;
  border-radius: 16px;
  overflow: hidden;
  backdrop-filter: blur(10px);
  background: rgba(255, 255, 255, 0.95);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  animation: slideUp 0.6s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.login-header {
  background: linear-gradient(135deg, #1976d2 0%, #1565c0 100%);
  color: white;
  text-align: center;
  padding: 2rem 1.5rem 1.5rem;
  position: relative;
}

.login-header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 20px;
  background: linear-gradient(to bottom, transparent, rgba(255, 255, 255, 0.1));
}

.login-icon-container {
  margin-bottom: 1rem;
  position: relative;
}

.login-icon {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

.login-title {
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.login-subtitle {
  font-size: 1rem;
  opacity: 0.9;
  margin: 0.5rem 0 0;
  font-weight: 400;
}

.login-content {
  padding: 2rem 1.5rem;
}

.security-info {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
  padding: 0.75rem;
  background: rgba(76, 175, 80, 0.1);
  border-radius: 8px;
  border-left: 4px solid #4caf50;
}

.login-description {
  text-align: center;
  color: #666;
  line-height: 1.6;
  margin-bottom: 1.5rem;
  font-size: 1rem;
}

.benefits-list {
  margin-bottom: 2rem;
}

.benefit-item {
  display: flex;
  align-items: center;
  margin-bottom: 0.75rem;
  padding: 0.5rem;
  border-radius: 6px;
  transition: background-color 0.2s;
}

.benefit-item:hover {
  background: rgba(25, 118, 210, 0.05);
}

.benefit-item span {
  margin-left: 0.75rem;
  font-size: 0.9rem;
  color: #555;
}

.github-login-button {
  height: 56px;
  font-weight: 600;
  text-transform: none;
  letter-spacing: 0.5px;
  font-size: 1.1rem;
  border-radius: 12px;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.github-login-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.github-login-button:hover::before {
  left: 100%;
}

.github-login-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(25, 118, 210, 0.3);
}

.trust-indicators {
  display: flex;
  justify-content: center;
  gap: 0.75rem;
  margin-top: 1.5rem;
}

.loading-card .login-header {
  background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%);
}

.loading-steps {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-top: 1rem;
}

.loading-step {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.loading-step.active {
  background: rgba(25, 118, 210, 0.1);
  color: #1976d2;
  font-weight: 600;
}

.loading-step span {
  font-size: 0.9rem;
}

.login-link {
  text-decoration: none;
  display: block;
}

/* Responsive Design */
@media (max-width: 768px) {
  .github-login-container {
    min-height: 100vh;
    padding: 10px;
  }
  
  .login-card {
    max-width: 100%;
    margin: 0;
    border-radius: 12px;
  }
  
  .login-header {
    padding: 1.5rem 1rem 1rem;
  }
  
  .login-title {
    font-size: 1.5rem;
  }
  
  .login-content {
    padding: 1.5rem 1rem;
  }
  
  .github-login-button {
    height: 52px;
    font-size: 1rem;
  }
  
  .trust-indicators {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .user-chip {
    max-width: 200px;
  }
  
  .user-name {
    font-size: 0.8rem;
  }
}

@media (max-width: 480px) {
  .login-header {
    padding: 1rem 0.75rem 0.75rem;
  }
  
  .login-title {
    font-size: 1.25rem;
  }
  
  .login-subtitle {
    font-size: 0.9rem;
  }
  
  .login-content {
    padding: 1rem 0.75rem;
  }
  
  .benefit-item {
    padding: 0.25rem;
  }
  
  .benefit-item span {
    font-size: 0.85rem;
  }
}

/* Estilos de autenticación removidos - ya no se necesita login */

.organization-info {
  background-color: #f5f5f5;
  border-left: 4px solid #1976d2;
}

/* Estilos para el logo y título corporativo */
.hdi-logo-container {
  background: transparent;
  border-radius: 8px;
  padding: 2px 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
}

.hdi-logo-svg {
  width: 60px;
  height: 60px;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
}

.title-content {
  display: flex;
  flex-direction: column;
}

.main-title {
  color: white;
  font-size: 24px;
  font-weight: 700;
  line-height: 1.2;
  margin-bottom: 4px;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
}

.subtitle {
  color: rgba(255, 255, 255, 0.9);
  font-size: 14px;
  font-weight: 400;
  line-height: 1.2;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

 /* Responsive para el título */
 @media (max-width: 768px) {
   .hdi-logo-svg {
     width: 50px;
     height: 50px;
   }
   
   .main-title {
     font-size: 20px;
   }
   
   .subtitle {
     font-size: 12px;
   }
 }

 @media (max-width: 480px) {
   .hdi-logo-svg {
     width: 45px;
     height: 45px;
   }
   
   .main-title {
     font-size: 18px;
   }
   
   .subtitle {
     font-size: 11px;
   }
 }

 /* Estilos personalizados para las pestañas */
 .custom-tabs {
   border-radius: 0 0 16px 16px;
   overflow: hidden;
   box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
 }

 .custom-tabs .v-tab {
   text-transform: none !important;
   font-weight: 600 !important;
   letter-spacing: 0.5px !important;
   transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
   position: relative !important;
   overflow: hidden !important;
 }

 .custom-tabs .v-tab:hover {
   background-color: rgba(255, 255, 255, 0.15) !important;
   transform: translateY(-2px) !important;
 }

 .custom-tabs .v-tab--selected {
   background: linear-gradient(135deg, #28a745, #20c997) !important;
   color: white !important;
   box-shadow: 0 4px 15px rgba(40, 167, 69, 0.4) !important;
   transform: translateY(-2px) !important;
 }

 .custom-tabs .v-tab--selected::before {
   content: '';
   position: absolute;
   bottom: 0;
   left: 50%;
   transform: translateX(-50%);
   width: 30px;
   height: 3px;
   background: white;
   border-radius: 2px;
   box-shadow: 0 2px 8px rgba(255, 255, 255, 0.5);
 }

 .custom-tabs .v-tab--selected .tab-icon {
   color: white !important;
   transform: scale(1.1) !important;
 }

 .custom-tabs .v-tab:not(.v-tab--selected) {
   color: rgba(255, 255, 255, 0.8) !important;
   background: rgba(255, 255, 255, 0.05) !important;
 }

 .custom-tabs .v-tab:not(.v-tab--selected):hover {
   color: white !important;
   background: rgba(255, 255, 255, 0.1) !important;
 }

 .tab-content {
   display: flex;
   align-items: center;
   justify-content: center;
   padding: 8px 16px;
   min-height: 44px;
 }

 .tab-icon {
   font-size: 20px !important;
   transition: all 0.3s ease !important;
 }

 .tab-text {
   font-size: 14px !important;
   font-weight: 600 !important;
   white-space: nowrap;
 }

 /* Indicador de pestaña activa */
 .custom-tabs .v-tabs-slider {
   background: white !important;
   height: 4px !important;
   border-radius: 2px !important;
   box-shadow: 0 2px 8px rgba(255, 255, 255, 0.6) !important;
 }

 /* Efectos adicionales para las pestañas */
 .custom-tabs .v-tab::after {
   content: '';
   position: absolute;
   top: 0;
   left: 0;
   right: 0;
   bottom: 0;
   background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.02), transparent);
   transform: translateX(-100%);
   transition: transform 0.6s ease;
   opacity: 0;
 }

 .custom-tabs .v-tab:hover::after {
   transform: translateX(100%);
   opacity: 0.3;
 }

 /* Animación para el cambio de pestaña */
 .custom-tabs .v-tab--selected .tab-content {
   animation: tabSelected 0.3s ease-out;
 }

 @keyframes tabSelected {
   0% {
     transform: scale(0.95);
     opacity: 0.8;
   }
   50% {
     transform: scale(1.05);
     opacity: 0.9;
   }
   100% {
     transform: scale(1);
     opacity: 1;
   }
 }

 /* Responsive para las pestañas */
 @media (max-width: 768px) {
   .custom-tabs {
     height: 50px !important;
   }
   
   .tab-content {
     padding: 6px 12px;
     min-height: 38px;
   }
   
   .tab-icon {
     font-size: 18px !important;
   }
   
   .tab-text {
     font-size: 13px !important;
   }
 }

 @media (max-width: 480px) {
   .custom-tabs {
     height: 45px !important;
   }
   
   .tab-content {
     padding: 4px 8px;
     min-height: 35px;
   }
   
   .tab-icon {
     font-size: 16px !important;
   }
   
   .tab-text {
     font-size: 12px !important;
   }
   
   .custom-tabs .v-tab {
     min-width: auto !important;
   }
 }

 /* Estilos para el toggle del selector de organizaciones */
 .org-selector-wrapper {
   margin: 16px 0;
   position: relative;
 }

 .org-selector-toggle {
   display: flex;
   align-items: center;
   justify-content: center;
   background: linear-gradient(135deg, #f8f9fa, #e9ecef);
   border: 2px solid #dee2e6;
   border-radius: 12px;
   padding: 12px 20px;
   cursor: pointer;
   transition: all 0.3s ease;
   box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
   margin-bottom: 8px;
 }

 .org-selector-toggle:hover {
   background: linear-gradient(135deg, #e9ecef, #dee2e6);
   border-color: #28a745;
   box-shadow: 0 4px 15px rgba(40, 167, 69, 0.2);
   transform: translateY(-1px);
 }

 .org-selector-toggle:active {
   transform: translateY(0);
   box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
 }

 .toggle-icon {
   margin-right: 8px;
   transition: transform 0.3s ease;
 }

 .toggle-icon.rotated {
   transform: rotate(180deg);
 }

 .toggle-text {
   font-weight: 600;
   color: #495057;
   font-size: 14px;
   user-select: none;
 }

 /* Responsive para el toggle */
 @media (max-width: 768px) {
   .org-selector-toggle {
     padding: 10px 16px;
   }
   
   .toggle-text {
     font-size: 13px;
   }
 }

 @media (max-width: 480px) {
   .org-selector-toggle {
     padding: 8px 12px;
   }
   
   .toggle-text {
     font-size: 12px;
   }
   
   .toggle-icon {
     margin-right: 6px;
   }
 }
</style>