<template>
  <v-app>
    <v-main class="main-content">
      <slot />
    </v-main>
    <v-footer class="bg-indigo-lighten-1 text-center d-flex flex-column fixed-footer">
      <div class="px-20 py-2 text-center w-100 d-flex align-center justify-center">
        <span>
          2025 — Copilot Metrics Viewer — 3.0 - Fork powered by DevOps HDI
        </span>
        <span class="footer-logo-wrapper">
            <img
              src="@/assets/devopsicon.png"
              alt="Logotipo DevOps HDI"
              class="footer-logo"
            />
          </span>
      </div>
    </v-footer>
  </v-app>
</template>

<script lang="ts" setup>
import getDisplayName from '~/../shared/utils/getDisplayName'

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
  background-color: #009739 !important; /* Verde HDI */
  color: #fff !important; /* Texto blanco */
  border-top: 2px solid #00712b; /* Borde HDI opcional */
}

.footer-logo-wrapper {
  margin-left: 12px;
  display: flex;
  align-items: center;
}

.footer-logo {
  height: 32px;
  filter: drop-shadow(0 0 2px #fff);
}

.main-content {
  padding: 0 16px 16px 16px;
}

/* Responsive margins */
@media (min-width: 600px) {
  .main-content {
    padding: 0 24px 24px 24px;
  }
}

@media (min-width: 960px) {
  .main-content {
    padding: 0 32px 32px 32px;
  }
}

@media (min-width: 1264px) {
  .main-content {
    padding: 0 48px 48px 48px;
  }
}

/* Ajustes de recorte y presentación del icono */
.footer-logo-wrapper {
  width: 40px;
  height: 40px;
  overflow: hidden;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-left: 8px;
  border-radius: 6px; /* opcional: suaviza bordes si el PNG no es circular */
}

.footer-logo {
  width: 100%;
  height: 100%;
  object-fit: cover; /* usa 'cover' para recortar márgenes transparentes */
  display: block;
  image-rendering: auto;
}
</style>
