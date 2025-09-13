#!/bin/bash

# Script para crear archivo de configuración en el servidor
# Uso: ./create-server-config.sh

echo "🔧 Creando archivo de configuración en el servidor..."

# Crear archivo de configuración con variables de entorno
cat > /home/Apps/statics/copilot-metrics/public/config.json << 'EOF'
{
  "githubToken": "",
  "githubOrg": "hdicl",
  "githubEnt": "",
  "githubTeam": "",
  "scope": "organization",
  "isDataMocked": true,
  "usingGithubAuth": true,
  "sessionPasswordLast4": "",
  "githubClientIdLast4": "",
  "githubClientSecretLast4": "",
  "version": "0.0.0",
  "timestamp": "2025-09-12T14:00:00Z"
}
EOF

echo "✅ Archivo de configuración creado en /home/Apps/statics/copilot-metrics/public/config.json"

# Crear script para actualizar configuración
cat > /home/Apps/scripts/update-config.sh << 'UPDATE_SCRIPT'
#!/bin/bash

# Script para actualizar configuración con variables de entorno actuales
echo "🔄 Actualizando configuración..."

# Leer variables de entorno (si están configuradas)
GITHUB_TOKEN=${GITHUB_TOKEN:-""}
GITHUB_ORG=${GITHUB_ORG:-"hdicl"}
GITHUB_ENT=${GITHUB_ENT:-""}
GITHUB_TEAM=${GITHUB_TEAM:-""}
SCOPE=${SCOPE:-"organization"}
IS_DATA_MOCKED=${IS_DATA_MOCKED:-"true"}
USING_GITHUB_AUTH=${USING_GITHUB_AUTH:-"true"}
SESSION_PASSWORD=${SESSION_PASSWORD:-""}
GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID:-""}
GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET:-""}
VERSION=${VERSION:-"0.0.0"}

# Crear archivo de configuración
cat > /home/Apps/statics/copilot-metrics/public/config.json << CONFIG_EOF
{
  "githubToken": "$GITHUB_TOKEN",
  "githubOrg": "$GITHUB_ORG",
  "githubEnt": "$GITHUB_ENT",
  "githubTeam": "$GITHUB_TEAM",
  "scope": "$SCOPE",
  "isDataMocked": $IS_DATA_MOCKED,
  "usingGithubAuth": $USING_GITHUB_AUTH,
  "sessionPasswordLast4": "${SESSION_PASSWORD: -4}",
  "githubClientIdLast4": "${GITHUB_CLIENT_ID: -4}",
  "githubClientSecretLast4": "${GITHUB_CLIENT_SECRET: -4}",
  "version": "$VERSION",
  "timestamp": "$(date -Iseconds)"
}
CONFIG_EOF

echo "✅ Configuración actualizada: $(date)"
echo "📋 Configuración actual:"
cat /home/Apps/statics/copilot-metrics/public/config.json | jq .
UPDATE_SCRIPT

chmod +x /home/Apps/scripts/update-config.sh

echo "✅ Script de actualización creado en /home/Apps/scripts/update-config.sh"
echo ""
echo "📋 Para usar:"
echo "1. Configura las variables de entorno en el servidor:"
echo "   export GITHUB_TOKEN='tu_token_aqui'"
echo "   export GITHUB_ORG='hdicl'"
echo "   export IS_DATA_MOCKED='false'"
echo "   export USING_GITHUB_AUTH='true'"
echo ""
echo "2. Ejecuta: /home/Apps/scripts/update-config.sh"
echo ""
echo "3. La aplicación cargará la configuración desde /config.json"
