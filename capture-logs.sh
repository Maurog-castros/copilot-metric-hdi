#!/bin/bash

echo "🔍 Capturando logs detallados del contenedor..."

# Función para capturar logs
capture_logs() {
    echo "📊 Estado del contenedor:"
    docker ps -a | grep copilot-metrics-hdi
    
    echo -e "\n📋 Logs del contenedor (últimas 100 líneas):"
    docker logs copilot-metrics-hdi --tail 100 2>&1
    
    echo -e "\n🔧 Variables de entorno del contenedor:"
    docker exec copilot-metrics-hdi env 2>/dev/null | grep NUXT || echo "No se pudieron obtener las variables de entorno"
    
    echo -e "\n📁 Archivos en /app:"
    docker exec copilot-metrics-hdi ls -la /app 2>/dev/null || echo "No se pudo acceder a /app"
    
    echo -e "\n🌐 Test de conectividad:"
    curl -I http://localhost:8080/copilot-metrics-hdi/ 2>&1
    
    echo -e "\n📄 Respuesta HTML (primeras 500 caracteres):"
    curl -s http://localhost:8080/copilot-metrics-hdi/ | head -c 500
    echo -e "\n..."
}

# Ejecutar captura
capture_logs

echo -e "\n🔄 Monitoreando logs en tiempo real (presiona Ctrl+C para salir):"
docker logs -f copilot-metrics-hdi 2>&1
