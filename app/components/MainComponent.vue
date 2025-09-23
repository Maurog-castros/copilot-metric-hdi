<template>
  <div>
    <!-- Toolbar HDI -->
    <v-toolbar v-if="!signInRequired || (signInRequired && isAuthenticated)" class="bg-hdi-universal-green" elevation="4">
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
      <h2 class="error-message">{{ mockedDataMessage }}</h2>
      <v-spacer />

      <!-- GitHub Authentication State -->
      <div v-show="isAuthenticated" class="user-info">
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
                <v-icon>mdi-logout</v-icon>
              </template>
              <v-list-item-title>Cerrar Sesión</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </div>

      <template #extension>
        <div class="d-flex align-center">
          <v-tabs
            v-model="tab"
            align-tabs="title"
            class="tabs-container"
          >
            <v-tab
              v-for="item in tabItems"
              :key="item"
              :value="item"
              class="tab-item"
            >
              <div class="tab-content">
                <v-icon class="tab-icon mr-2">{{ getTabIcon(item) }}</v-icon>
                <span class="tab-text">{{ item }}</span>
              </div>
            </v-tab>
          </v-tabs>

          <!-- Botón de modo oscuro -->
          <v-btn
            :icon="isDarkMode ? 'mdi-weather-sunny' : 'mdi-weather-night'"
            variant="text"
            size="small"
            class="dark-mode-toggle ml-4"
            @click="toggleDarkMode"
            :title="isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'"
          />
        </div>
      </template>
    </v-toolbar>

    <!-- Date Range Selector - Hidden for seats tab -->
    <DateRangeSelector
      v-show="tab !== 'seat analysis' && !signInRequired"
      :loading="isLoading"
      @date-range-changed="handleDateRangeChange" />

    <!-- Organization info for seats tab -->
    <div v-if="tab === 'seat analysis'" class="organization-info">
      <v-card flat class="pa-3 mb-2">
        <div class="text-body-2 text-center">
          Displaying data for organization: <strong>{{ displayName }}</strong>
        </div>
      </v-card>
    </div>

    <!-- API Error Message -->
    <div v-show="apiError && !signInRequired" class="error-message" v-text="apiError" />
    <AuthState>
      <template #default="{ loggedIn }">
        <div v-show="signInRequired" class="github-login-container">
          <NuxtLink v-if="!loggedIn && signInRequired" to="/auth/github" class="github-login-button"> <v-icon
              left>mdi-github</v-icon>
            Sign in with GitHub</NuxtLink>
        </div>
      </template>
      <template #placeholder>
        <button disabled>Loading...</button>
      </template>
    </AuthState>


    <div v-show="!apiError">
      <v-progress-linear v-show="!metricsReady" indeterminate color="indigo" />
      <v-window v-show="(metricsReady && metrics.length) || (seatsReady && tab === 'seat analysis')" v-model="tab">
        <v-window-item v-for="item in tabItems" :key="item" :value="item">
          <v-card flat>
            <MetricsViewer v-if="item === getDisplayTabName(itemName) || item === 'Organización' || item === 'Empresa' || item === 'Equipo'" :metrics="metrics" :date-range-description="dateRangeDescription" />
            <TeamsComponent v-if="item === 'Equipos'" :date-range-description="dateRangeDescription" :date-range="dateRange" />
            <BreakdownComponent
              v-if="item === 'Lenguajes'" :metrics="metrics" :breakdown-key="'language'"
              :date-range-description="dateRangeDescription" />
            <BreakdownComponent
              v-if="item === 'Editores'" :metrics="metrics" :breakdown-key="'editor'"
              :date-range-description="dateRangeDescription" />
            <CopilotChatViewer
              v-if="item === 'Chat Copilot'" :metrics="metrics"
              :date-range-description="dateRangeDescription" />
            <AgentModeViewer v-if="item === 'GitHub.com'" :original-metrics="originalMetrics" :date-range="dateRange" :date-range-description="dateRangeDescription" />
            <SeatsAnalysisViewer v-if="item === 'Análisis de asientos'" :seats="seats" />
            <ApiResponse
              v-if="item === 'Respuesta API'" :metrics="metrics" :original-metrics="originalMetrics"
              :seats="seats" />
          </v-card>
        </v-window-item>
        <v-alert
          v-show="(metricsReady && metrics.length == 0 && tab !== 'seat analysis') || (seatsReady && seats.length == 0 && tab === 'seat analysis')"
          density="compact" text="No data available to display" title="No data" type="warning" />
      </v-window>

    </div>

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
import { Options } from '@/model/Options';
import { useRoute } from 'vue-router';

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
    DateRangeSelector
  },
  methods: {
    logout() {
      const { clear } = useUserSession()
      this.metrics = [];
      this.seats = [];
      clear();
    },
    toggleDarkMode() {
      this.isDarkMode = !this.isDarkMode;
      // Aplicar la clase dark-mode al body
      if (this.isDarkMode) {
        document.body.classList.add('dark-mode');
        localStorage.setItem('darkMode', 'true');
      } else {
        document.body.classList.remove('dark-mode');
        localStorage.setItem('darkMode', 'false');
      }
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
      // Return appropriate icon for each tab
      switch (tabName.toLowerCase()) {
        case 'organization':
          return 'mdi-office-building';
        case 'enterprise':
          return 'mdi-domain';
        case 'team':
        case 'teams':
          return 'mdi-account-group';
        case 'languages':
          return 'mdi-code-tags';
        case 'editors':
          return 'mdi-code-braces';
        case 'copilot chat':
          return 'mdi-chat';
        case 'github.com':
          return 'mdi-github';
        case 'seat analysis':
          return 'mdi-account-multiple';
        case 'api response':
          return 'mdi-api';
        default:
          return 'mdi-chart-line';
      }
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
    async fetchMetrics() {
      if (this.signInRequired || !this.dateRange.since || !this.dateRange.until || this.isLoading) {
        return;
      }
      const config = useRuntimeConfig();

      this.isLoading = true;
      // Clear previous API errors when making a new request
      this.apiError = undefined;

      try {
        const options = Options.fromRoute(this.route, this.dateRange.since, this.dateRange.until);

        // Add holiday options if they're set
        if (this.holidayOptions?.excludeHolidays) {
          options.excludeHolidays = this.holidayOptions.excludeHolidays;
        }

        const params = options.toParams();

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
        this.processError(error);
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
  tabItems: ['Lenguajes', 'Editores', 'Chat Copilot', 'GitHub.com', 'Análisis de asientos', 'Respuesta API'],
      tab: null,
      dateRangeDescription: 'Over the last 28 days',
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
      isDarkMode: false
    }
  },
  created() {
    // Traducción de la pestaña principal
    const tabNameMap: Record<string, string> = {
      organization: 'Organización',
      enterprise: 'Empresa',
      team: 'Equipo',
      'team-organization': 'Equipo',
      'team-enterprise': 'Equipo'
    };
    const displayTab = tabNameMap[this.getDisplayTabName(this.itemName)] || this.getDisplayTabName(this.itemName);
    this.tabItems.unshift(displayTab);

    // Add teams tab for organization and enterprise scopes to allow team comparison
    if (this.itemName === 'organization' || this.itemName === 'enterprise') {
      this.tabItems.splice(1, 0, 'Equipos'); // Insertar después de la pestaña principal
    }

    this.config = useRuntimeConfig();
  },
  async mounted() {
    // Cargar estado del modo oscuro desde localStorage
    const savedDarkMode = localStorage.getItem('darkMode');
    if (savedDarkMode === 'true') {
      this.isDarkMode = true;
      document.body.classList.add('dark-mode');
    }

    // Load initial data
    try {

      await this.fetchMetrics();

      const { data: seatsData, error: seatsError, execute: executeSeats } = this.seatsFetch;

      if (!this.signInRequired) {
        await executeSeats();

        if (seatsError.value) {
          this.processError(seatsError.value as H3Error);
        } else {
          this.seats = (seatsData.value as Seat[]) || [];
          this.seatsReady = true;
        }
      }

    } catch (error) {
      console.error('Error loading initial data:', error);
    }
  },
  async setup() {
    const { loggedIn, user } = useUserSession()
    const config = useRuntimeConfig();
    const showLogoutButton = computed(() => config.public.usingGithubAuth && loggedIn.value);
    const mockedDataMessage = computed(() => config.public.isDataMocked ? 'Using mock data - see README if unintended' : '');
    const itemName = computed(() => config.public.scope);
    const githubInfo = getDisplayName(config.public)
    const displayName = computed(() => githubInfo);
    const dateRange = ref({ since: undefined as string | undefined, until: undefined as string | undefined });
    const isLoading = ref(false);
    const route = ref(useRoute());

    const signInRequired = computed(() => {
      return config.public.usingGithubAuth && !loggedIn.value;
    });

    const isAuthenticated = computed(() => {
      return loggedIn.value;
    });

    const seatsFetch = useFetch('/api/seats', {
      server: true,
      immediate: !signInRequired.value,
      query: computed(() => {
        const options = Options.fromRoute(route.value);
        return options.toParams();
      })
    });

    return {
      showLogoutButton,
      mockedDataMessage,
      itemName,
      displayName,
      signInRequired,
      isAuthenticated,
      user,
      seatsFetch,
      dateRange,
      isLoading,
      route,
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

.logout-button {
  margin-left: auto;
}

.github-login-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.github-login-button {
  display: flex;
  align-items: center;
  background-color: #24292e;
  color: white;
  padding: 10px 20px;
  border-radius: 5px;
  text-decoration: none;
  font-weight: bold;
  font-size: 14px;
}

.github-login-button:hover {
  background-color: #444d56;
}

/* Estilos para el botón de modo oscuro */
.dark-mode-toggle {
  color: white !important;
  transition: all 0.3s ease;
}

.dark-mode-toggle:hover {
  background-color: rgba(255, 255, 255, 0.1) !important;
  transform: scale(1.1);
}

.dark-mode-toggle .v-icon {
  color: white !important;
}

.github-login-button v-icon {
  margin-right: 8px;
}

.user-info {
  display: flex;
  align-items: center;
}

.user-avatar {
  margin-right: 8px;
  margin-left: 8px;
  border: 2px solid white;
}

.organization-info {
  background-color: #f5f5f5;
  border-left: 4px solid #1976d2;
}

/* Estilos específicos para el header HDI */
.bg-hdi-universal-green {
  background: linear-gradient(135deg, #65A518 0%, #006729 100%) !important;
}

.toolbar-title {
  color: white !important;
}

.hdi-logo-svg {
  height: 40px;
  width: auto;
}

.title-content {
  display: flex;
  flex-direction: column;
}

.main-title {
  font-size: 1.5rem;
  font-weight: bold;
  color: white;
}

.subtitle {
  font-size: 0.9rem;
  color: rgba(255, 255, 255, 0.8);
}

.error-message {
  color: #ff6b6b;
  font-size: 0.9rem;
  margin-left: 1rem;
}

.user-chip {
  background-color: rgba(255, 255, 255, 0.1) !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
}

.user-chip .user-name {
  color: white !important;
  font-weight: 500;
}

.tabs-container {
  background-color: rgba(255, 255, 255, 0.1);
}

.tab-item {
  color: rgba(255, 255, 255, 0.8) !important;
}

.tab-item.v-tab--selected {
  color: white !important;
}

.tab-content {
  display: flex;
  align-items: center;
}

.tab-icon {
  color: inherit;
}

.tab-text {
  font-weight: 500;
}

/* Responsive para el header HDI */
@media (max-width: 768px) {
  .main-title {
    font-size: 1.2rem;
  }

  .subtitle {
    font-size: 0.8rem;
  }

  .hdi-logo-svg {
    height: 32px;
  }
}
</style>
