# -----------------------------------
# Stage 1: Build the Nuxt application
# mode puede ser 'prod' (default) o 'playwright'
# Ejemplo build prod: docker build -t copilot-metrics .
# Ejemplo build pw:   docker build -t copilot-metrics-pw --build-arg mode=playwright .
# -----------------------------------
ARG mode=prod

FROM node:20-slim AS build-stage

# Crear usuario sin privilegios
RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nuxt

WORKDIR /app
USER nuxt

# Copiar dependencias primero
COPY --chown=nuxt:nodejs package*.json ./
RUN npm install --omit=dev

# Copiar el resto del código y compilar
COPY --chown=nuxt:nodejs . .
RUN npm run build

# -----------------------------------
# Stage 2: Base image para producción
# -----------------------------------
FROM node:20-slim AS base-prod

WORKDIR /app

# Copiar solo la salida de build
COPY --chown=1001:1001 --from=build-stage /app/.output /app

# Exponer puerto (80 para compatibilidad)
EXPOSE 80
ENV NITRO_PORT=80

# Script de entrypoint para mapear variables de entorno
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_IS_DATA_MOCKED=${NUXT_PUBLIC_IS_DATA_MOCKED:-$VUE_APP_MOCKED_DATA}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_SCOPE=${NUXT_PUBLIC_SCOPE:-$VUE_APP_SCOPE}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_GITHUB_ORG=${NUXT_PUBLIC_GITHUB_ORG:-$VUE_APP_GITHUB_ORG}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_GITHUB_ENT=${NUXT_PUBLIC_GITHUB_ENT:-$VUE_APP_GITHUB_ENT}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_GITHUB_TEAM=${NUXT_PUBLIC_GITHUB_TEAM:-$VUE_APP_GITHUB_TEAM}' >> /entrypoint.sh && \
    echo 'export NUXT_GITHUB_TOKEN=${NUXT_GITHUB_TOKEN:-$VUE_APP_GITHUB_TOKEN}' >> /entrypoint.sh && \
    echo 'export NUXT_SESSION_PASSWORD=${NUXT_SESSION_PASSWORD:-$SESSION_SECRET$SESSION_SECRET}' >> /entrypoint.sh && \
    echo 'export NUXT_SESSION_PASSWORD=${NUXT_SESSION_PASSWORD:-$NUXT_GITHUB_TOKEN$NUXT_GITHUB_TOKEN}' >> /entrypoint.sh && \
    echo 'export NUXT_OAUTH_GITHUB_CLIENT_ID=${NUXT_OAUTH_GITHUB_CLIENT_ID:-$GITHUB_CLIENT_ID}' >> /entrypoint.sh && \
    echo 'export NUXT_OAUTH_GITHUB_CLIENT_SECRET=${NUXT_OAUTH_GITHUB_CLIENT_SECRET:-$GITHUB_CLIENT_SECRET}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_USING_GITHUB_AUTH=${NUXT_PUBLIC_USING_GITHUB_AUTH:-false}' >> /entrypoint.sh && \
    echo 'export NODE_ENV=development' >> /entrypoint.sh && \
    echo 'export DEBUG=*' >> /entrypoint.sh && \
    echo 'export NODE_OPTIONS="--trace-warnings --trace-uncaught"' >> /entrypoint.sh && \
    echo 'node /app/debug-logger.js' >> /entrypoint.sh && \
    echo 'exec node --trace-warnings --trace-uncaught /app/server/index.mjs' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

USER 1001
ENTRYPOINT [ "/entrypoint.sh" ]

# -----------------------------------
# Stage 3: Playwright layer (solo para tests)
# -----------------------------------
FROM mcr.microsoft.com/playwright:v1.54.2 AS base-playwright

WORKDIR /pw

RUN apt-get update && \
    apt-get install -y --no-install-recommends gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=1000:1000 --from=base-prod /app /app
COPY --chown=1000:1000 e2e-tests ./e2e-tests
COPY --chown=1000:1000 playwright.config.ts playwright.docker.config.ts tsconfig.json package*.json ./

RUN NODE_ENV=development npm install

ENTRYPOINT [ "npx", "playwright", "test", "-c", "playwright.docker.config.ts", "--workers", "2"]

# -----------------------------------
FROM base-${mode} AS final
