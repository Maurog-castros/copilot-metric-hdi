# 📊 GitHub Copilot Metrics Viewer (HDI Edition)

<p align="center">
  <img width="180" alt="HDI Seguros Logo" src="https://www.hdi.cl/media/100122/logo_hdi_solo.png">
</p>

---

## 🚀 Resumen del Proyecto
El proyecto es una versión personalizada (fork) del **GitHub Copilot Metrics Viewer**, adaptada específicamente para **HDI Seguros**. Está diseñado para visualizar métricas de adopción y uso de GitHub Copilot en organizaciones o empresas.
------------------------------------------------------------------------

## 🎯 Propósito

Esta implementación es una versión personalizada del **GitHub Copilot
Metrics Viewer**, adaptada para entornos empresariales como **HDI
Seguros**, con foco en:

-   Medición de adopción por equipo\
-   Análisis comparativo de uso\
-   Segmentación por modelo y editor\
-   Exportación de datos para análisis externo\
-   Soporte dual de autenticación (PAT / OAuth)

El objetivo es habilitar **toma de decisiones basada en datos** respecto
a licenciamiento, adopción y retorno de inversión (ROI) de Copilot.

------------------------------------------------------------------------

## 🏗️ Arquitectura

### Stack Principal

  -----------------------------------------------------------------------
  Capa                    Tecnología
  ----------------------- -----------------------------------------------
  Framework               Nuxt.js (estructura moderna con `app/`,
                          `server/`, `shared/`)

  UI                      Vuetify 3 + tema corporativo personalizado

  Backend                 Nitro Server (integrado en Nuxt)

  Autenticación           GitHub OAuth / Personal Access Token

  Infraestructura         Docker + Nginx Reverse Proxy
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 🔐 Modos de Autenticación

### 1️⃣ Modo PAT (Sin OAuth)

-   Uso de Personal Access Token fijo\
-   Ideal para ambientes internos o PoC\
-   Configuración simple

### 2️⃣ Modo OAuth

-   Login vía GitHub\
-   Multiusuario\
-   Más seguro y alineado a buenas prácticas enterprise

------------------------------------------------------------------------

## 🐳 Despliegue

Totalmente dockerizado.

Permite ejecutar: - Versión PAT\
- Versión OAuth\
- Ambas simultáneamente en el mismo host mediante Nginx reverse proxy

------------------------------------------------------------------------

## 📂 Estructura del Proyecto

``` bash
.
├── app/               # Frontend (pages, components, composables)
├── server/            # API endpoints (Nitro)
├── shared/            # Código compartido cliente-servidor
├── public/            # Recursos estáticos
│
├── docs/              # Configuración principal y guías
├── infrastructure/    # Nginx, Azure, scripts de despliegue
├── testing/           # Unit & E2E tests (Vitest / Playwright)
├── examples/          # Casos de referencia
└── README.md
```

------------------------------------------------------------------------

## 🚀 Ejecución en Desarrollo

``` bash
npm install
npm run dev
```

Aplicación disponible en:

    http://localhost:3000

------------------------------------------------------------------------

## 🏗️ Build de Producción

``` bash
npm run build
npm run preview
```

------------------------------------------------------------------------

## 📊 Funcionalidades Clave

-   ✔ Filtrado por rango de fechas (hasta 100 días)\
-   ✔ Comparación entre equipos\
-   ✔ Métricas por modelo de Copilot\
-   ✔ Métricas por editor (VS Code, JetBrains, etc.)\
-   ✔ Exportación CSV\
-   ✔ Interfaz responsive

------------------------------------------------------------------------

## 📈 Casos de Uso

-   Evaluación de ROI de GitHub Copilot\
-   Identificación de equipos con baja adopción\
-   Justificación de renovación/licenciamiento\
-   Seguimiento mensual de uso\
-   Reportes ejecutivos para Gerencia TI

------------------------------------------------------------------------

## 🔧 Configuración Recomendada (Enterprise)

-   Uso de OAuth en producción\
-   Variables sensibles vía `.env`\
-   Reverse proxy con TLS\
-   Logs centralizados\
-   Rate limit y control de acceso por red interna

------------------------------------------------------------------------

## 🧪 Testing

Incluye:

-   Tests unitarios (Vitest)\
-   Tests E2E (Playwright)

``` bash
npm run test
```

------------------------------------------------------------------------

## 📌 Roadmap Técnico

-   [ ] Integración con base de datos para histórico persistente\
-   [ ] Métricas acumuladas mensuales\
-   [ ] Dashboard comparativo multi-organización\
-   [ ] Exportación PDF ejecutiva\
-   [ ] Integración con Power BI

------------------------------------------------------------------------

## 🧠 Enfoque Estratégico

Más que un visor técnico, esta implementación busca transformar métricas
de uso en:

-   Información accionable\
-   Optimización de costos\
-   Cultura de medición DevOps\
-   Madurez en adopción de IA en desarrollo

------------------------------------------------------------------------

## 🏢 Contexto

Adaptado para ecosistemas empresariales con prácticas DevOps maduras y
gobierno TI formal.