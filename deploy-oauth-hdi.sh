#!/bin/bash

# Script de despliegue para Copilot Metrics Viewer con OAuth en HDI
# Este script configura nginx correctamente para manejar las rutas OAuth

set -e

echo "🚀 Iniciando despliegue de Copilot Metrics Viewer con OAuth..."

# Variables
NGINX_CONFIG="/etc/nginx/sites-available/copilot-metrics-oauth"
NGINX_ENABLED="/etc/nginx/sites-enabled/copilot-metrics-oauth"
DOCKER_COMPOSE_FILE="docker-compose.hdi.yml"
NGINX_CONFIG_FILE="nginx-oauth-hdi.conf"

# Verificar que estamos en el directorio correcto
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "❌ Error: No se encontró $DOCKER_COMPOSE_FILE"
    echo "   Asegúrate de ejecutar este script desde el directorio del proyecto"
    exit 1
fi

if [ ! -f "$NGINX_CONFIG_FILE" ]; then
    echo "❌ Error: No se encontró $NGINX_CONFIG_FILE"
    echo "   Asegúrate de que el archivo de configuración nginx existe"
    exit 1
fi

# Verificar que nginx está instalado
if ! command -v nginx &> /dev/null; then
    echo "❌ Error: nginx no está instalado"
    echo "   Instala nginx: sudo apt update && sudo apt install nginx"
    exit 1
fi

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado"
    echo "   Instala Docker: https://docs.docker.com/engine/install/"
    exit 1
fi

# Verificar que Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: Docker Compose no está instalado"
    echo "   Instala Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Verificaciones de dependencias completadas"

# Detener servicios existentes
echo "🛑 Deteniendo servicios existentes..."
sudo systemctl stop nginx 2>/dev/null || true
docker-compose -f $DOCKER_COMPOSE_FILE down 2>/dev/null || true

# Construir y levantar la aplicación
echo "🔨 Construyendo y levantando la aplicación..."
docker-compose -f $DOCKER_COMPOSE_FILE build --no-cache
docker-compose -f $DOCKER_COMPOSE_FILE up -d

# Esperar a que la aplicación esté lista
echo "⏳ Esperando a que la aplicación esté lista..."
sleep 30

# Verificar que la aplicación está funcionando
echo "🔍 Verificando que la aplicación esté funcionando..."
if curl -f http://localhost:3000/health >/dev/null 2>&1; then
    echo "✅ Aplicación funcionando correctamente"
else
    echo "❌ Error: La aplicación no está respondiendo en el puerto 3000"
    echo "   Revisa los logs: docker-compose -f $DOCKER_COMPOSE_FILE logs"
    exit 1
fi

# Configurar nginx
echo "🔧 Configurando nginx..."

# Copiar configuración de nginx
sudo cp $NGINX_CONFIG_FILE $NGINX_CONFIG

# Crear enlace simbólico
sudo ln -sf $NGINX_CONFIG $NGINX_ENABLED

# Verificar configuración de nginx
echo "🔍 Verificando configuración de nginx..."
if sudo nginx -t; then
    echo "✅ Configuración de nginx válida"
else
    echo "❌ Error: Configuración de nginx inválida"
    echo "   Revisa el archivo: $NGINX_CONFIG"
    exit 1
fi

# Reiniciar nginx
echo "🔄 Reiniciando nginx..."
sudo systemctl restart nginx
sudo systemctl enable nginx

# Verificar que nginx está funcionando
echo "🔍 Verificando que nginx esté funcionando..."
if sudo systemctl is-active --quiet nginx; then
    echo "✅ Nginx funcionando correctamente"
else
    echo "❌ Error: Nginx no está funcionando"
    echo "   Revisa los logs: sudo journalctl -u nginx"
    exit 1
fi

# Verificar que las rutas OAuth funcionan
echo "🔍 Verificando rutas OAuth..."
if curl -f http://localhost/auth/github >/dev/null 2>&1; then
    echo "✅ Ruta OAuth funcionando correctamente"
else
    echo "⚠️  Advertencia: Ruta OAuth no responde (esto es normal si no hay HTTPS)"
    echo "   En producción, asegúrate de configurar HTTPS"
fi

# Verificar que la aplicación principal funciona
echo "🔍 Verificando aplicación principal..."
if curl -f http://localhost/ >/dev/null 2>&1; then
    echo "✅ Aplicación principal funcionando correctamente"
else
    echo "❌ Error: Aplicación principal no responde"
    echo "   Revisa los logs: docker-compose -f $DOCKER_COMPOSE_FILE logs"
    exit 1
fi

echo ""
echo "🎉 ¡Despliegue completado exitosamente!"
echo ""
echo "📋 Resumen del despliegue:"
echo "   • Aplicación: http://localhost/"
echo "   • Health check: http://localhost/health"
echo "   • Ruta OAuth: http://localhost/auth/github"
echo "   • Configuración nginx: $NGINX_CONFIG"
echo ""
echo "🔧 Comandos útiles:"
echo "   • Ver logs de la aplicación: docker-compose -f $DOCKER_COMPOSE_FILE logs -f"
echo "   • Ver logs de nginx: sudo tail -f /var/log/nginx/copilot-metrics-oauth.access.log"
echo "   • Reiniciar aplicación: docker-compose -f $DOCKER_COMPOSE_FILE restart"
echo "   • Reiniciar nginx: sudo systemctl restart nginx"
echo ""
echo "⚠️  Nota: Para producción, asegúrate de:"
echo "   • Configurar HTTPS con certificados SSL"
echo "   • Actualizar el server_name en nginx-oauth-hdi.conf"
echo "   • Configurar firewall para permitir puertos 80 y 443"
echo "   • Verificar que las URLs de callback OAuth coincidan"
