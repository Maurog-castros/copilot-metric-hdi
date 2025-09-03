<template>
  <v-app>
    <v-main>
      <div class="site-container">
        <slot />
      </div>
    </v-main>
    <v-footer class="bg-indigo-lighten-1 text-center d-flex flex-column fixed-footer">
      <div class="px-4 py-2 text-center w-100">
        {{ new Date().getFullYear() }} — <strong><a href="https://github.com/github-copilot-resources/copilot-metrics-viewer" target="_blank" rel="noopener noreferrer" style="color: inherit;">Copilot Metrics Viewer</a></strong> — {{ version }} — <strong>Fork - DevOps - HDI</strong>
      </div>
    </v-footer>
  </v-app>
</template>

<script lang="ts" setup>
const config = useRuntimeConfig();
const version = computed(() => config.public.version);
const githubInfo = getDisplayName(config.public)
useHead({
  title: githubInfo,
  meta: [
    { name: 'description', content: 'Copilot Metrics Dashboard' }
  ]
});
</script>

<style scoped>
.fixed-footer {
  height: 50px;
  max-height: 50px;
}

.site-container {
  width: 95%;
  max-width: 95%;
  margin: 0 auto;
  padding: 0 20px;
}

/* Responsive para el contenedor */
@media (max-width: 1200px) {
  .site-container {
    width: 98%;
    padding: 0 15px;
  }
}

@media (max-width: 768px) {
  .site-container {
    width: 100%;
    padding: 0 10px;
  }
}
</style>
