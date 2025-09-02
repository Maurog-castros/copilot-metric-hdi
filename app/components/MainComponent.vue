<template>
  <div>
          <v-toolbar class="bg-hdi-universal-green" elevation="4">
      <v-btn icon>
        <v-icon>mdi-github</v-icon>
      </v-btn>

             <v-toolbar-title class="toolbar-title">
         <div class="d-flex align-center">
           <div class="hdi-logo-container mr-3">
             <img src="/assets/hdi.svg" alt="HDI Logo" class="hdi-logo-svg" />
           </div>
           <div class="title-content">
             <div class="main-title">Panel de Métricas de Copilot</div>
             <div class="subtitle">Organización: {{ displayName }}</div>
           </div>
         </div>
       </v-toolbar-title>
      <h2 class="error-message"> {{ mockedDataMessage }} </h2>
      <v-spacer />

      <!-- Conditionally render the logout button -->
      <AuthState>
        <template #default="{ loggedIn, user }">
          <div v-show="loggedIn" class="user-info">
            Welcome,
            <v-avatar class="user-avatar">
              <v-img :alt="user?.name" :src="user?.avatarUrl" />
            </v-avatar> {{ user?.name }}
          </div>
          <v-btn v-if="showLogoutButton && loggedIn" class="logout-button" @click="logout">Logout</v-btn>
        </template>
      </AuthState>

      <template #extension>

        <v-tabs v-model="tab" align-tabs="title">
          <v-tab v-for="item in tabItems" :key="item" :value="item">
            {{ item }}
          </v-tab>
        </v-tabs>

      </template>

    </v-toolbar>

    <!-- Date Range Selector - Hidden for seats tab -->
         <DateRangeSelector 
       v-show="tab !== 'análisis de asientos' && !signInRequired" 
       :loading="isLoading"
       @date-range-changed="handleDateRangeChange" />

    <!-- Organization info for seats tab -->
         <div v-if="tab === 'análisis de asientos'" class="organization-info">
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
          <NuxtLink v-if="!loggedIn && signInRequired" to="/auth/github" external class="github-login-button"> <v-icon
              left>mdi-github</v-icon>
            Sign in with GitHub</NuxtLink>
        </div>
      </template>
      <template #placeholder>
        <button disabled>Loading...</button>
      </template>
    </AuthState>


    <div v-show="!apiError">
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
        excludeHolidays: newDateRange.excludeHolidays,
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
      tabItems: ['lenguajes', 'editores', 'chat copilot', 'github.com', 'análisis de asientos', 'respuesta api'],
      tab: null,
      dateRangeDescription: 'Durante los últimos 28 días',
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
      }
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
</style>