# 🤖 Copilot AI Agent Instructions for HDI Copilot Metrics Viewer

## Big Picture & Architecture
- **Purpose:** Dashboard profesional para monitoreo y análisis del uso de GitHub Copilot en HDI Seguros Chile.
- **Stack:** Nuxt.js 4 (Vue 3, Vuetify), Node.js (API), Docker, Nginx (prod), GitHub OAuth, nuxt-auth-utils.
- **Estructura:**
  - `/app/` Componentes, layouts, páginas y lógica de UI.
  - `/server/api/` Endpoints API (TypeScript, para datos y webhooks).
  - `/public/` Recursos estáticos y mock-data.
  - `.env` Centraliza todas las variables sensibles y de entorno.
  - `/infra/` Infraestructura como código (Bicep, scripts de despliegue).
- **Flujo:**
  1. Usuario inicia sesión vía GitHub OAuth.
  2. Se valida token y permisos (middleware).
  3. Se consultan métricas vía API GitHub y se procesan para dashboards.
  4. Webhooks opcionales para eventos en tiempo real.

## Workflows Clave
- **Desarrollo local:**
  - `npm install` para dependencias.
  - `npm run dev` para entorno local (lee `.env`).
  - Variables críticas: `NUXT_GITHUB_TOKEN`, `NUXT_SESSION_PASSWORD`, `NUXT_OAUTH_GITHUB_CLIENT_ID`, `NUXT_OAUTH_GITHUB_CLIENT_SECRET`.
- **Pruebas:**
  - `npm test` (unitarias con Vitest).
  - E2E: `npm run test:e2e` (Playwright, ver `/e2e-tests/`).
- **Despliegue:**
  - Docker: `docker build -t hdi-copilot-metrics .` y `docker run -p 8080:80 --env-file .env hdi-copilot-metrics`.
  - Health checks expuestos para monitoreo.

## Convenciones y Patrones
- **Variables de entorno:** Solo `.env` debe usarse (no `config.env`).
- **Autenticación:**
  - Middleware en `/middleware/auth.ts` protege rutas.
  - Sesiones encriptadas, password mínimo 32 caracteres.
- **Componentes:**
  - UI modular en `/app/components/`.
  - Composables reutilizables en `/app/composables/`.
- **API:**
  - Endpoints en `/server/api/` usan TypeScript y validan input.
  - Webhook GitHub: `/server/api/webhook.ts` (firma validada con `GITHUB_WEBHOOK_SECRET`).
- **Organizaciones:**
  - Configuración en `/app/config/organizations.ts` (solo `hdicl` por defecto).
- **Datos mock:**
  - Activar con `NUXT_PUBLIC_IS_DATA_MOCKED=true` para desarrollo sin API real.

## Integraciones y Dependencias
- **GitHub:**
  - Personal Access Token y OAuth App requeridos.
  - Webhook opcional para eventos (configurar secret en `.env`).
- **nuxt-auth-utils:**
  - Usado para flujos de autenticación y sesión.
- **Docker/Nginx:**
  - Ver `Dockerfile`, `nginx-hdi.conf` y scripts de despliegue para producción.

## Ejemplo de .env mínimo
```
NUXT_GITHUB_TOKEN=xxx
NUXT_SESSION_PASSWORD=xxx32charsxxx
NUXT_OAUTH_GITHUB_CLIENT_ID=xxx
NUXT_OAUTH_GITHUB_CLIENT_SECRET=xxx
GITHUB_WEBHOOK_SECRET=xxx
```

---

Para dudas sobre patrones o flujos, revisa también el README.md y los scripts en `/scripts/`.
