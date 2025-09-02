#!/bin/bash

# Script de despliegue para HDI
# Este script construye y despliega la aplicación en Docker

set -e

echo "🚀 Iniciando despliegue de Copilot Metrics Viewer para HDI..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

# Verificar si Docker Compose está disponible
if ! command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose no está disponible. Usando 'docker compose' (nueva sintaxis)..."
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Verificar archivo .env
if [ ! -f .env ]; then
    print_warning "Archivo .env no encontrado. Copiando desde env.hdi.example..."
    if [ -f env.hdi.example ]; then
        cp env.hdi.example .env
        print_warning "Por favor edita el archivo .env con tus credenciales antes de continuar."
        print_warning "Presiona Enter cuando hayas configurado el archivo .env..."
        read
    else
        print_error "Archivo env.hdi.example no encontrado. Por favor crea un archivo .env manualmente."
        exit 1
    fi
fi

# Crear directorio de logs si no existe
mkdir -p logs

print_status "Construyendo imagen Docker..."
$DOCKER_COMPOSE -f docker-compose.hdi.yml build

print_status "Deteniendo contenedores existentes..."
$DOCKER_COMPOSE -f docker-compose.hdi.yml down

print_status "Iniciando aplicación..."
$DOCKER_COMPOSE -f docker-compose.hdi.yml up -d

print_status "Esperando que la aplicación esté lista..."
sleep 10

# Verificar estado de la aplicación
if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
    print_status "✅ Aplicación desplegada exitosamente!"
    print_status "🌐 La aplicación está disponible en: http://localhost:3000"
    print_status "📊 Panel de métricas: http://localhost:3000"
    print_status "🔍 Health check: http://localhost:3000/api/health"
else
    print_warning "La aplicación puede estar aún iniciando. Verificando logs..."
    $DOCKER_COMPOSE -f docker-compose.hdi.yml logs --tail=20
    print_warning "Si hay problemas, revisa los logs con: $DOCKER_COMPOSE -f docker-compose.hdi.yml logs -f"
fi

echo ""
print_status "Comandos útiles:"
echo "  Ver logs: $DOCKER_COMPOSE -f docker-compose.hdi.yml logs -f"
echo "  Detener: $DOCKER_COMPOSE -f docker-compose.hdi.yml down"
echo "  Reiniciar: $DOCKER_COMPOSE -f docker-compose.hdi.yml restart"
echo "  Estado: $DOCKER_COMPOSE -f docker-compose.hdi.yml ps"
