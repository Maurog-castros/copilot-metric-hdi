import { defineVuetifyConfiguration } from 'vuetify-nuxt-module/custom-configuration'

export default defineVuetifyConfiguration({
  // your Vuetify options here
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          // Keep existing Vuetify colors but add custom hover states
          primary: '#1976D2',
          secondary: '#424242',
          accent: '#82B1FF',
          error: '#FF5252',
          info: '#2196F3',
          success: '#4CAF50',
          warning: '#FFC107',
          // Custom surface colors for better hover effects
          surface: '#FFFFFF',
          'surface-variant': '#F5F5F5',
        },
      },
      dark: {
        colors: {
          // Dark theme colors with HDI corporate identity
          primary: '#4FC3F7',
          secondary: '#757575',
          accent: '#64B5F6',
          error: '#F44336',
          info: '#29B6F6',
          success: '#66BB6A',
          warning: '#FFB74D',
          // Dark surface colors
          surface: '#121212',
          'surface-variant': '#1E1E1E',
          background: '#0D1117',
          'on-background': '#F0F6FC',
          'on-surface': '#F0F6FC',
        },
      },
    },
  },
})
