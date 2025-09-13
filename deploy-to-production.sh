#!/bin/bash

# Script completo de despliegue a producción HDI
# Ejecutar en el servidor: bash deploy-to-production.sh

set -e

echo "🚀 Iniciando despliegue completo de Copilot Metrics Viewer en HDI..."

# Variables
PROJECT_DIR="/home/Apps/copilot-metrics-hdi"
REPO_URL="https://github.com/Maurog-castros/copilot-metric-hdi.git"
NGINX_CONFIG="/etc/nginx/sites-available/copilot-metrics-oauth"
NGINX_ENABLED="/etc/nginx/sites-enabled/copilot-metrics-oauth"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos ejecutando como usuario correcto
if [ "$USER" != "mcastro" ]; then
    print_warning "Ejecutando como usuario: $USER"
    print_warning "Se recomienda ejecutar como usuario 'mcastro'"
fi

# Crear directorio del proyecto
print_status "Creando directorio del proyecto..."
sudo mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Clonar o actualizar repositorio
if [ -d ".git" ]; then
    print_status "Actualizando repositorio existente..."
    git pull origin main
else
    print_status "Clonando repositorio..."
    git clone $REPO_URL .
fi

# Verificar archivos necesarios
print_status "Verificando archivos necesarios..."
required_files=(
    "docker-compose.hdi.yml"
    "nginx-oauth-hdi.conf"
    "env.hdi.example"
    "Dockerfile.hdi"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Archivo requerido no encontrado: $file"
        exit 1
    fi
done

print_success "Todos los archivos necesarios están presentes"

# Configurar variables de entorno
print_status "Configurando variables de entorno..."
if [ ! -f ".env" ]; then
    cp env.hdi.example .env
    print_warning "Archivo .env creado desde plantilla. REVISA LA CONFIGURACIÓN:"
    print_warning "nano .env"
    print_warning "Asegúrate de configurar las credenciales OAuth correctas"
    read -p "Presiona Enter cuando hayas revisado y configurado el archivo .env..."
else
    print_success "Archivo .env ya existe"
fi

# Verificar Docker
print_status "Verificando Docker..."
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado"
    print_status "Instalando Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    print_warning "Docker instalado. Es necesario reiniciar sesión para aplicar permisos"
fi

# Verificar Docker Compose
print_status "Verificando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose no está instalado"
    print_status "Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Verificar nginx
print_status "Verificando nginx..."
if ! command -v nginx &> /dev/null; then
    print_error "nginx no está instalado"
    print_status "Instalando nginx..."
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
fi

# Detener servicios existentes
print_status "Deteniendo servicios existentes..."
sudo systemctl stop nginx 2>/dev/null || true
docker-compose -f docker-compose.hdi.yml down 2>/dev/null || true

# Construir y levantar la aplicación
print_status "Construyendo y levantando la aplicación..."
docker-compose -f docker-compose.hdi.yml build --no-cache
docker-compose -f docker-compose.hdi.yml up -d

# Esperar a que la aplicación esté lista
print_status "Esperando a que la aplicación esté lista..."
sleep 30

# Verificar que la aplicación está funcionando
print_status "Verificando que la aplicación esté funcionando..."
max_attempts=10
attempt=1

while [ $attempt -le $max_attempts ]; do
    if curl -f http://localhost:3000/health >/dev/null 2>&1; then
        print_success "Aplicación funcionando correctamente"
        break
    else
        print_warning "Intento $attempt/$max_attempts - Esperando aplicación..."
        sleep 10
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    print_error "La aplicación no está respondiendo después de $max_attempts intentos"
    print_status "Revisando logs..."
    docker-compose -f docker-compose.hdi.yml logs
    exit 1
fi

# Configurar nginx
print_status "Configurando nginx..."

# Copiar configuración de nginx
sudo cp nginx-oauth-hdi.conf $NGINX_CONFIG

# Crear enlace simbólico
sudo ln -sf $NGINX_CONFIG $NGINX_ENABLED

# Verificar configuración de nginx
print_status "Verificando configuración de nginx..."
if sudo nginx -t; then
    print_success "Configuración de nginx válida"
else
    print_error "Configuración de nginx inválida"
    print_status "Revisando configuración..."
    sudo nginx -t
    exit 1
fi

# Reiniciar nginx
print_status "Reiniciando nginx..."
sudo systemctl restart nginx
sudo systemctl enable nginx

# Verificar que nginx está funcionando
print_status "Verificando que nginx esté funcionando..."
if sudo systemctl is-active --quiet nginx; then
    print_success "Nginx funcionando correctamente"
else
    print_error "Nginx no está funcionando"
    print_status "Revisando logs de nginx..."
    sudo journalctl -u nginx --no-pager -l
    exit 1
fi

# Verificar que las rutas OAuth funcionan
print_status "Verificando rutas OAuth..."
if curl -f http://localhost/auth/github >/dev/null 2>&1; then
    print_success "Ruta OAuth funcionando correctamente"
else
    print_warning "Ruta OAuth no responde (esto es normal si no hay HTTPS)"
    print_warning "En producción, asegúrate de configurar HTTPS"
fi

# Verificar que la aplicación principal funciona
print_status "Verificando aplicación principal..."
if curl -f http://localhost/ >/dev/null 2>&1; then
    print_success "Aplicación principal funcionando correctamente"
else
    print_error "Aplicación principal no responde"
    print_status "Revisando logs..."
    docker-compose -f docker-compose.hdi.yml logs
    exit 1
fi

# Mostrar resumen final
echo ""
print_success "¡Despliegue completado exitosamente!"
echo ""
print_status "📋 Resumen del despliegue:"
echo "   • Aplicación: http://localhost/"
echo "   • Health check: http://localhost/health"
echo "   • Ruta OAuth: http://localhost/auth/github"
echo "   • Configuración nginx: $NGINX_CONFIG"
echo ""
print_status "🔧 Comandos útiles:"
echo "   • Ver logs de la aplicación: docker-compose -f docker-compose.hdi.yml logs -f"
echo "   • Ver logs de nginx: sudo tail -f /var/log/nginx/copilot-metrics-oauth.access.log"
echo "   • Reiniciar aplicación: docker-compose -f docker-compose.hdi.yml restart"
echo "   • Reiniciar nginx: sudo systemctl restart nginx"
echo ""
print_warning "⚠️  Notas importantes:"
echo "   • Para producción, configura HTTPS con certificados SSL"
echo "   • Actualiza el server_name en nginx-oauth-hdi.conf si es necesario"
echo "   • Configura firewall para permitir puertos 80 y 443"
echo "   • Verifica que las URLs de callback OAuth coincidan con GitHub"
echo ""
print_success "🎉 ¡El sistema está listo para usar!"
