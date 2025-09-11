#!/bin/bash

echo "🔧 Reconstruyendo contenedor con logging detallado..."

# Parar y eliminar contenedor existente
echo "🛑 Parando contenedor existente..."
docker stop copilot-metrics-hdi 2>/dev/null || echo "Contenedor no estaba corriendo"
docker rm copilot-metrics-hdi 2>/dev/null || echo "Contenedor no existía"

# Reconstruir imagen
echo "🏗️ Reconstruyendo imagen Docker..."
docker build --no-cache -t copilot-metric-hdi-copilot-metrics-hdi .

# Ejecutar contenedor
echo "🚀 Ejecutando nuevo contenedor..."
docker run -d --name copilot-metrics-hdi -p 8080:80 copilot-metric-hdi-copilot-metrics-hdi

# Esperar un momento
echo "⏳ Esperando que el contenedor inicie..."
sleep 5

# Mostrar logs
echo "📋 Logs del contenedor:"
docker logs copilot-metrics-hdi

echo "✅ Contenedor reconstruido con logging detallado"
echo "🌐 URL: http://vskpip01.hdi.chile:8080/copilot-metrics-hdi/"
echo "📊 Para ver logs en tiempo real: docker logs -f copilot-metrics-hdi"
