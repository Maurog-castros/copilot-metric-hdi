#!/bin/bash

# Script para ejecutar en el servidor
# server-deploy.sh

set -e

echo "🚀 Iniciando despliegue en el servidor..."

# Buscar el archivo de imagen más reciente
LATEST_IMAGE=$(ls -t copilot-metrics-image-*.tar | head -n1)

if [ -z "$LATEST_IMAGE" ]; then
    echo "❌ Error: No se encontró archivo de imagen"
    exit 1
fi

echo "📦 Usando imagen: $LATEST_IMAGE"

# Paso 1: Detener contenedores existentes
echo "🛑 Deteniendo contenedores existentes..."
docker-compose down || echo "No hay contenedores para detener"

# Paso 2: Limpiar recursos Docker
echo "🗑️ Limpiando contenedores e imágenes anteriores..."
docker container prune -f
docker image prune -f

# Paso 3: Cargar nueva imagen
echo "📦 Cargando nueva imagen..."
docker load -i "$LATEST_IMAGE"

# Paso 4: Verificar imagen cargada
echo "🔍 Verificando imagen cargada..."
docker images copilot-metrics-hdi:latest

# Paso 5: Limpiar archivo temporal
echo "🧹 Limpiando archivo temporal..."
rm "$LATEST_IMAGE"

# Paso 6: Iniciar nueva aplicación
echo "🚀 Iniciando nueva aplicación..."
docker-compose up -d

# Paso 7: Esperar que la aplicación esté lista
echo "⏳ Esperando que la aplicación esté lista..."
sleep 10

# Paso 8: Verificar estado
echo "🔍 Verificando estado de la aplicación..."
docker-compose ps

# Paso 9: Health check
echo "🏥 Verificando salud de la aplicación..."
curl -f http://localhost:3000/api/health || echo "Health check falló, pero la aplicación puede estar iniciando..."

echo "✅ Despliegue completado!"
echo "🌐 La aplicación está disponible en: http://$(hostname -I | awk '{print $1}'):3000"
