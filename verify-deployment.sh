#!/bin/bash

# Script de verificación post-despliegue
# Ejecutar después del despliegue para verificar que todo funciona

set -e

echo "🔍 Verificando despliegue de Copilot Metrics Viewer..."

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar Docker
print_status "Verificando Docker..."
if docker ps | grep -q copilot-metrics; then
    print_success "Contenedor Docker ejecutándose"
else
    print_error "Contenedor Docker no encontrado"
    exit 1
fi

# Verificar nginx
print_status "Verificando nginx..."
if systemctl is-active --quiet nginx; then
    print_success "Nginx ejecutándose"
else
    print_error "Nginx no está ejecutándose"
    exit 1
fi

# Verificar aplicación principal
print_status "Verificando aplicación principal..."
if curl -f http://localhost/ >/dev/null 2>&1; then
    print_success "Aplicación principal accesible"
else
    print_error "Aplicación principal no accesible"
    exit 1
fi

# Verificar health check
print_status "Verificando health check..."
if curl -f http://localhost/health >/dev/null 2>&1; then
    print_success "Health check funcionando"
else
    print_error "Health check no funciona"
    exit 1
fi

# Verificar ruta OAuth
print_status "Verificando ruta OAuth..."
oauth_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/auth/github)
if [ "$oauth_response" = "302" ] || [ "$oauth_response" = "200" ]; then
    print_success "Ruta OAuth funcionando (HTTP $oauth_response)"
else
    print_warning "Ruta OAuth responde con HTTP $oauth_response (puede ser normal)"
fi

# Verificar API de configuración
print_status "Verificando API de configuración..."
if curl -f http://localhost/api/config >/dev/null 2>&1; then
    print_success "API de configuración funcionando"
else
    print_error "API de configuración no funciona"
fi

# Verificar API de validación del servidor
print_status "Verificando API de validación del servidor..."
if curl -f http://localhost/api/validate/server-config >/dev/null 2>&1; then
    print_success "API de validación del servidor funcionando"
else
    print_error "API de validación del servidor no funciona"
fi

# Verificar logs de errores
print_status "Verificando logs de errores..."
error_count=$(docker-compose -f docker-compose.hdi.yml logs 2>&1 | grep -i error | wc -l)
if [ "$error_count" -eq 0 ]; then
    print_success "No se encontraron errores en los logs"
else
    print_warning "Se encontraron $error_count errores en los logs"
    print_status "Revisando errores..."
    docker-compose -f docker-compose.hdi.yml logs 2>&1 | grep -i error | head -5
fi

# Verificar puertos
print_status "Verificando puertos..."
if netstat -tlnp | grep -q ":80 "; then
    print_success "Puerto 80 abierto"
else
    print_error "Puerto 80 no está abierto"
fi

if netstat -tlnp | grep -q ":3000 "; then
    print_success "Puerto 3000 abierto"
else
    print_error "Puerto 3000 no está abierto"
fi

# Verificar espacio en disco
print_status "Verificando espacio en disco..."
disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$disk_usage" -lt 80 ]; then
    print_success "Espacio en disco suficiente ($disk_usage% usado)"
else
    print_warning "Espacio en disco bajo ($disk_usage% usado)"
fi

# Verificar memoria
print_status "Verificando memoria..."
memory_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ "$memory_usage" -lt 80 ]; then
    print_success "Memoria suficiente ($memory_usage% usada)"
else
    print_warning "Memoria alta ($memory_usage% usada)"
fi

# Mostrar resumen
echo ""
print_success "🎉 Verificación completada!"
echo ""
print_status "📋 Resumen de verificación:"
echo "   • Aplicación: http://localhost/"
echo "   • Health check: http://localhost/health"
echo "   • Ruta OAuth: http://localhost/auth/github"
echo "   • API Config: http://localhost/api/config"
echo "   • API Validación: http://localhost/api/validate/server-config"
echo ""
print_status "🔧 Comandos útiles:"
echo "   • Ver logs: docker-compose -f docker-compose.hdi.yml logs -f"
echo "   • Reiniciar: docker-compose -f docker-compose.hdi.yml restart"
echo "   • Estado: docker-compose -f docker-compose.hdi.yml ps"
echo ""
print_success "¡El sistema está listo para usar!"
