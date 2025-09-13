#!/bin/bash

# Script para configurar variables de entorno en el servidor
# Uso: ./setup-server-config.sh

echo "🔧 Configurando variables de entorno en el servidor..."

# Crear archivo de configuración
cat > /home/Apps/statics/copilot-metrics/public/config.json << 'EOF'
{
  "githubToken": "${GITHUB_TOKEN}",
  "githubOrg": "${GITHUB_ORG}",
  "scope": "${SCOPE}",
  "isDataMocked": "${IS_DATA_MOCKED}",
  "usingGithubAuth": "${USING_GITHUB_AUTH}",
  "version": "${VERSION}",
  "timestamp": "$(date -Iseconds)"
}
EOF

echo "✅ Archivo de configuración creado en /home/Apps/statics/copilot-metrics/public/config.json"

# Crear script para actualizar configuración
cat > /home/Apps/scripts/update-config.sh << 'EOF'
#!/bin/bash

# Script para actualizar configuración con variables de entorno actuales
cat > /home/Apps/statics/copilot-metrics/public/config.json << CONFIG_EOF
{
  "githubToken": "${GITHUB_TOKEN:-}",
  "githubOrg": "${GITHUB_ORG:-hdicl}",
  "scope": "${SCOPE:-organization}",
  "isDataMocked": "${IS_DATA_MOCKED:-false}",
  "usingGithubAuth": "${USING_GITHUB_AUTH:-true}",
  "version": "${VERSION:-0.0.0}",
  "timestamp": "$(date -Iseconds)"
}
CONFIG_EOF

echo "✅ Configuración actualizada: $(date)"
EOF

chmod +x /home/Apps/scripts/update-config.sh

echo "✅ Script de actualización creado en /home/Apps/scripts/update-config.sh"
echo ""
echo "📋 Para usar:"
echo "1. Configura las variables de entorno en el servidor"
echo "2. Ejecuta: /home/Apps/scripts/update-config.sh"
echo "3. La aplicación cargará la configuración desde /config.json"
