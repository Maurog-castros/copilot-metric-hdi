<template>
  <v-app>
    <v-main>
      <div class="site-container">
        <slot />
      </div>
    </v-main>
    <v-footer class="bg-gradient-footer text-center d-flex flex-column fixed-footer">
      <div class="footer-content px-4 py-3 w-100">
        <div class="footer-main">
          <!-- Lado izquierdo -->
          <div class="footer-left">
            <div class="footer-year">
              <v-icon color="white" size="16" class="mr-1">mdi-calendar-star</v-icon>
              <span class="footer-text">{{ new Date().getFullYear() }}</span>
            </div>
            
            <div class="footer-separator">
              <v-icon color="rgba(255,255,255,0.6)" size="12">mdi-diamond-stone</v-icon>
            </div>
            
            <div class="footer-project">
              <v-icon color="white" size="16" class="mr-1">mdi-github</v-icon>
              <a href="https://github.com/github-copilot-resources/copilot-metrics-viewer" 
                 target="_blank" 
                 rel="noopener noreferrer" 
                 class="footer-link">
                <strong>Copilot Metrics Viewer</strong>
              </a>
            </div>
            
            <div class="footer-separator">
              <v-icon color="rgba(255,255,255,0.6)" size="12">mdi-diamond-stone</v-icon>
            </div>
            
            <div class="footer-version">
              <v-chip 
                size="x-small" 
                color="success" 
                variant="elevated"
                class="version-chip"
              >
                <v-icon start size="12">mdi-tag</v-icon>
                {{ version }}
              </v-chip>
            </div>
          </div>

          <!-- Centro - DevOps destacado -->
          <div class="footer-center">
            <div class="devops-highlight">
              <v-icon color="white" size="24" class="devops-icon">mdi-cogs</v-icon>
              <span class="devops-text">HDI - Team DevOps</span>
            </div>
          </div>

          <!-- Lado derecho -->
          <div class="footer-right">
            <div class="footer-brand">
              <v-icon color="white" size="16" class="mr-1">mdi-source-fork</v-icon>
              <span class="footer-text">Fork</span>
            </div>
            
            <div class="footer-separator">
              <v-icon color="rgba(255,255,255,0.6)" size="12">mdi-diamond-stone</v-icon>
            </div>
            
            <div class="footer-hdi">
              <v-icon color="white" size="16" class="mr-1">mdi-domain</v-icon>
              <span class="footer-text brand-highlight">HDI</span>
            </div>
            
            <div class="footer-separator">
              <v-icon color="rgba(255,255,255,0.6)" size="12">mdi-diamond-stone</v-icon>
            </div>
            
            <!-- Toggle de tema -->
            <div class="theme-toggle">
              <v-btn
                :icon="isDark ? 'mdi-weather-sunny' : 'mdi-weather-night'"
                :color="isDark ? 'warning' : 'primary'"
                variant="text"
                size="small"
                @click="toggleTheme"
                class="theme-toggle-btn"
              >
                <v-icon size="20">{{ isDark ? 'mdi-weather-sunny' : 'mdi-weather-night' }}</v-icon>
                <v-tooltip activator="parent" location="top">
                  {{ isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro' }}
                </v-tooltip>
              </v-btn>
            </div>
          </div>
        </div>
      </div>
    </v-footer>
  </v-app>
</template>

<script lang="ts" setup>
const config = useRuntimeConfig();
const version = computed(() => config.public.version);
const githubInfo = getDisplayName(config.public)

// Theme management
const { $vuetify } = useNuxtApp()
const isDark = ref(false)

// Initialize theme from localStorage or system preference
onMounted(() => {
  const savedTheme = localStorage.getItem('hdi-theme')
  if (savedTheme) {
    isDark.value = savedTheme === 'dark'
    $vuetify.theme.global.name.value = savedTheme
  } else {
    // Use system preference
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    isDark.value = prefersDark
    $vuetify.theme.global.name.value = prefersDark ? 'dark' : 'light'
    localStorage.setItem('hdi-theme', prefersDark ? 'dark' : 'light')
  }
})

// Toggle theme function
const toggleTheme = () => {
  isDark.value = !isDark.value
  const newTheme = isDark.value ? 'dark' : 'light'
  $vuetify.theme.global.name.value = newTheme
  localStorage.setItem('hdi-theme', newTheme)
}

useHead({
  title: githubInfo,
  meta: [
    { name: 'description', content: 'Copilot Metrics Dashboard' }
  ]
});
</script>

<style scoped>
/* Footer principal */
.fixed-footer {
  height: 60px;
  max-height: 60px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
  border-radius: 16px 16px 0 0;
}

.bg-gradient-footer {
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 25%, #1976d2 50%, #1565c0 75%, #0d47a1 100%);
  position: relative;
  overflow: hidden;
}

.bg-gradient-footer::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.05) 50%, transparent 70%);
  animation: shimmer 3s infinite;
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

/* Contenido del footer */
.footer-content {
  position: relative;
  z-index: 1;
}

.footer-main {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 16px;
  min-height: 36px;
  position: relative;
}

.footer-left,
.footer-right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.footer-left {
  justify-content: flex-start;
}

.footer-right {
  justify-content: flex-end;
}

.footer-center {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  position: relative;
  z-index: 2;
}

/* Elementos del footer */
.footer-year,
.footer-project,
.footer-version,
.footer-brand,
.footer-hdi,
.theme-toggle {
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s ease;
  padding: 4px 8px;
  border-radius: 6px;
}

.footer-year:hover,
.footer-project:hover,
.footer-version:hover,
.footer-brand:hover,
.footer-hdi:hover,
.theme-toggle:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-1px);
}

/* Botón de toggle de tema */
.theme-toggle-btn {
  transition: all 0.3s ease !important;
  border-radius: 50% !important;
  min-width: 40px !important;
  height: 40px !important;
  background: rgba(255, 255, 255, 0.1) !important;
  backdrop-filter: blur(10px) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
}

.theme-toggle-btn:hover {
  background: rgba(255, 255, 255, 0.2) !important;
  transform: scale(1.1) !important;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3) !important;
}

.theme-toggle-btn .v-icon {
  transition: all 0.3s ease !important;
}

.theme-toggle-btn:hover .v-icon {
  transform: rotate(180deg) !important;
}

/* Elemento DevOps destacado */
.devops-highlight {
  display: flex;
  align-items: center;
  gap: 8px;
  background: linear-gradient(135deg, #28a745, #20c997, #17a2b8);
  background-size: 200% 200%;
  padding: 8px 16px;
  border-radius: 20px;
  box-shadow: 0 4px 15px rgba(40, 167, 69, 0.4);
  border: 2px solid rgba(255, 255, 255, 0.2);
  position: relative;
  overflow: hidden;
  animation: devopsGlow 3s ease-in-out infinite, devopsGradient 4s ease-in-out infinite;
  cursor: pointer;
  transition: all 0.3s ease;
}

.devops-highlight::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s ease;
}

.devops-highlight:hover::before {
  left: 100%;
}

.devops-highlight:hover {
  transform: scale(1.05) translateY(-2px);
  box-shadow: 0 6px 20px rgba(40, 167, 69, 0.6);
}

.devops-icon {
  animation: cogsRotate 3s linear infinite;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3));
}

.devops-text {
  color: white;
  font-weight: 700;
  font-size: 16px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
  letter-spacing: 1px;
  text-transform: uppercase;
  position: relative;
  z-index: 1;
}

@keyframes devopsGlow {
  0%, 100% { 
    box-shadow: 0 4px 15px rgba(40, 167, 69, 0.4);
  }
  50% { 
    box-shadow: 0 6px 20px rgba(40, 167, 69, 0.7);
  }
}

@keyframes devopsGradient {
  0%, 100% { 
    background-position: 0% 50%;
  }
  50% { 
    background-position: 100% 50%;
  }
}

@keyframes cogsRotate {
  0% { 
    transform: rotate(0deg);
  }
  100% { 
    transform: rotate(360deg);
  }
}

.footer-text {
  color: white;
  font-weight: 500;
  font-size: 14px;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

.footer-link {
  color: white !important;
  text-decoration: none;
  transition: all 0.3s ease;
  font-weight: 600;
  position: relative;
}

.footer-link:hover {
  color: #4fc3f7 !important;
  text-shadow: 0 0 8px rgba(79, 195, 247, 0.6);
  transform: scale(1.05);
}

.footer-link::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 0;
  height: 2px;
  background: linear-gradient(90deg, #4fc3f7, #29b6f6);
  transition: width 0.3s ease;
}

.footer-link:hover::after {
  width: 100%;
}

/* Separadores */
.footer-separator {
  display: flex;
  align-items: center;
  margin: 0 4px;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 0.6; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.1); }
}

/* Chip de versión */
.version-chip {
  font-weight: 600 !important;
  box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3) !important;
  animation: glow 2s infinite alternate;
}

@keyframes glow {
  from { box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3); }
  to { box-shadow: 0 2px 12px rgba(76, 175, 80, 0.5); }
}

/* Destacado de marca HDI */
.brand-highlight {
  background: linear-gradient(135deg, #28a745, #20c997);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  font-weight: 700 !important;
  text-shadow: none;
  position: relative;
}

.brand-highlight::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #28a745, #20c997);
  border-radius: 4px;
  padding: 2px 6px;
  margin: -2px -6px;
  z-index: -1;
  opacity: 0.2;
}

/* Contenedor del sitio */
.site-container {
  width: 95%;
  max-width: 95%;
  margin: 0 auto;
  padding: 0 20px 40px 20px;
  min-height: calc(100vh - 120px);
}

/* Responsive para el footer */
@media (max-width: 1200px) {
  .site-container {
    width: 98%;
    padding: 0 15px 35px 15px;
  }
  
  .footer-main {
    gap: 6px;
  }
  
  .footer-text {
    font-size: 13px;
  }
}

@media (max-width: 768px) {
  .site-container {
    width: 100%;
    padding: 0 10px 30px 10px;
  }
  
  .fixed-footer {
    height: auto;
    min-height: 80px;
    margin-bottom: 15px;
  }
  
  .footer-main {
    flex-direction: column;
    gap: 12px;
    padding: 12px 0;
  }
  
  .footer-left,
  .footer-right {
    justify-content: center;
    gap: 6px;
  }
  
  .footer-center {
    order: -1;
    margin-bottom: 8px;
  }
  
  .devops-highlight {
    padding: 6px 12px;
  }
  
  .devops-text {
    font-size: 14px;
  }
  
  .devops-icon {
    font-size: 20px !important;
  }
  
  .footer-year,
  .footer-project,
  .footer-version,
  .footer-brand,
  .footer-hdi,
  .theme-toggle {
    padding: 2px 4px;
  }
  
  .theme-toggle-btn {
    min-width: 36px !important;
    height: 36px !important;
  }
  
  .footer-text {
    font-size: 12px;
  }
  
  .footer-separator {
    display: none;
  }
}

@media (max-width: 480px) {
  .site-container {
    padding: 0 8px 25px 8px;
  }
  
  .fixed-footer {
    margin-bottom: 10px;
  }
  
  .footer-content {
    padding: 8px 12px;
  }
  
  .footer-text {
    font-size: 11px;
  }
  
  .version-chip {
    transform: scale(0.9);
  }
}

/* Animaciones adicionales */
.footer-main > * {
  animation: slideInUp 0.6s ease-out;
}

.footer-main > *:nth-child(1) { animation-delay: 0.1s; }
.footer-main > *:nth-child(2) { animation-delay: 0.2s; }
.footer-main > *:nth-child(3) { animation-delay: 0.3s; }
.footer-main > *:nth-child(4) { animation-delay: 0.4s; }
.footer-main > *:nth-child(5) { animation-delay: 0.5s; }
.footer-main > *:nth-child(6) { animation-delay: 0.6s; }
.footer-main > *:nth-child(7) { animation-delay: 0.7s; }
.footer-main > *:nth-child(8) { animation-delay: 0.8s; }
.footer-main > *:nth-child(9) { animation-delay: 0.9s; }

@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Estilos para modo oscuro */
.v-theme--dark .bg-gradient-footer {
  background: linear-gradient(135deg, #0d1117 0%, #161b22 25%, #21262d 50%, #30363d 75%, #484f58 100%);
}

.v-theme--dark .devops-highlight {
  background: linear-gradient(135deg, #28a745, #20c997, #17a2b8);
  box-shadow: 0 4px 15px rgba(40, 167, 69, 0.6);
}

.v-theme--dark .devops-highlight:hover {
  box-shadow: 0 6px 20px rgba(40, 167, 69, 0.8);
}

.v-theme--dark .theme-toggle-btn {
  background: rgba(255, 255, 255, 0.05) !important;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
}

.v-theme--dark .theme-toggle-btn:hover {
  background: rgba(255, 255, 255, 0.15) !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
}
</style>
