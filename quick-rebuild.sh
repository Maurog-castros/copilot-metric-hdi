#!/bin/bash

echo "🚀 Reconstrucción rápida del contenedor..."

# Parar y eliminar contenedor existente
echo "🛑 Parando contenedor existente..."
docker stop copilot-metrics-hdi 2>/dev/null || echo "Contenedor no estaba corriendo"
docker rm copilot-metrics-hdi 2>/dev/null || echo "Contenedor no existía"

# Reconstruir imagen (solo si hay cambios en el código)
echo "🏗️ Reconstruyendo imagen..."
docker build --no-cache -t copilot-metric-hdi-copilot-metrics-hdi .

# Ejecutar nuevo contenedor
echo "🚀 Ejecutando nuevo contenedor..."
docker run -d --name copilot-metrics-hdi -p 8080:80 copilot-metric-hdi-copilot-metrics-hdi

# Esperar un momento
echo "⏳ Esperando que el contenedor inicie..."
sleep 3

# Verificar estado
echo "✅ Verificando estado..."
docker ps | grep copilot-metrics-hdi

echo "🌐 Aplicación disponible en:"
echo "   Local: http://localhost:8080/copilot-metrics-hdi/"
echo "   Remoto: http://vskpip01.hdi.chile:8080/copilot-metrics-hdi/"
echo ""
echo "📋 Para ver logs: docker logs -f copilot-metrics-hdi"
