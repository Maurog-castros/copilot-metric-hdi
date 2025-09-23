# Dockerfile.production (multi-stage optimizado)
FROM node:23-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:23-alpine AS production
WORKDIR /app

# Copiar dependencias del stage anterior
COPY --from=dependencies /app/node_modules ./node_modules

# Copiar archivos del build
COPY --chown=1000:1000 .output/ /app/
COPY --chown=1000:1000 package*.json /app/

EXPOSE 80
ENV NITRO_PORT=80

# Script de entrypoint (mantener existente)
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_IS_DATA_MOCKED=${NUXT_PUBLIC_IS_DATA_MOCKED:-$VUE_APP_MOCKED_DATA}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_SCOPE=${NUXT_PUBLIC_SCOPE:-$VUE_APP_SCOPE}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_GITHUB_ORG=${NUXT_PUBLIC_GITHUB_ORG:-$VUE_APP_GITHUB_ORG}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_GITHUB_ENT=${NUXT_PUBLIC_GITHUB_ENT:-$VUE_APP_GITHUB_ENT}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_GITHUB_TEAM=${NUXT_PUBLIC_GITHUB_TEAM:-$VUE_APP_GITHUB_TEAM}' >> /entrypoint.sh && \
    echo 'export NUXT_GITHUB_TOKEN=${NUXT_GITHUB_TOKEN:-$VUE_APP_GITHUB_TOKEN}' >> /entrypoint.sh && \
    echo 'export NUXT_SESSION_PASSWORD=${NUXT_SESSION_PASSWORD:-$SESSION_SECRET$SESSION_SECRET$SESSION_SECRET$SESSION_SECRET}' >> /entrypoint.sh && \
    echo 'export NUXT_OAUTH_GITHUB_CLIENT_ID=${NUXT_OAUTH_GITHUB_CLIENT_ID:-$GITHUB_CLIENT_ID}' >> /entrypoint.sh && \
    echo 'export NUXT_OAUTH_GITHUB_CLIENT_SECRET=${NUXT_OAUTH_GITHUB_CLIENT_SECRET:-$GITHUB_CLIENT_SECRET}' >> /entrypoint.sh && \
    echo 'export NUXT_OAUTH_GITHUB_CLIENT_SCOPE=${NUXT_OAUTH_GITHUB_CLIENT_SCOPE:-read:org,read:user}' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_IS_PUBLIC_APP=${NUXT_PUBLIC_IS_PUBLIC_APP:-false}' >> /entrypoint.sh && \
    echo 'if [ -n "$GITHUB_CLIENT_ID" ]; then' >> /entrypoint.sh && \
    echo 'export NUXT_PUBLIC_USING_GITHUB_AUTH=true' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo 'node /app/server/index.mjs' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

USER node
ENTRYPOINT [ "/entrypoint.sh" ]