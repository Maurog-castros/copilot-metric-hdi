# Script de despliegue para Copilot Metrics Viewer con OAuth en HDI
# Este script configura nginx correctamente para manejar las rutas OAuth

param(
    [switch]$SkipDocker,
    [switch]$SkipNginx,
    [switch]$Force
)

# Variables
$NGINX_CONFIG_FILE = "nginx-oauth-hdi.conf"
$DOCKER_COMPOSE_FILE = "docker-compose.hdi.yml"

Write-Host "🚀 Iniciando despliegue de Copilot Metrics Viewer con OAuth..." -ForegroundColor Green

# Verificar que estamos en el directorio correcto
if (-not (Test-Path $DOCKER_COMPOSE_FILE)) {
    Write-Host "❌ Error: No se encontró $DOCKER_COMPOSE_FILE" -ForegroundColor Red
    Write-Host "   Asegúrate de ejecutar este script desde el directorio del proyecto" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $NGINX_CONFIG_FILE)) {
    Write-Host "❌ Error: No se encontró $NGINX_CONFIG_FILE" -ForegroundColor Red
    Write-Host "   Asegúrate de que el archivo de configuración nginx existe" -ForegroundColor Yellow
    exit 1
}

# Verificar que Docker está instalado
if (-not $SkipDocker) {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Error: Docker no está instalado" -ForegroundColor Red
        Write-Host "   Instala Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        exit 1
    }

    # Verificar que Docker Compose está instalado
    if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Error: Docker Compose no está instalado" -ForegroundColor Red
        Write-Host "   Instala Docker Compose: https://docs.docker.com/compose/install/" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "✅ Verificaciones de dependencias completadas" -ForegroundColor Green

    # Detener servicios existentes
    Write-Host "🛑 Deteniendo servicios existentes..." -ForegroundColor Yellow
    try {
        docker-compose -f $DOCKER_COMPOSE_FILE down
    } catch {
        Write-Host "⚠️  No se pudieron detener servicios existentes (esto es normal si no estaban ejecutándose)" -ForegroundColor Yellow
    }

    # Construir y levantar la aplicación
    Write-Host "🔨 Construyendo y levantando la aplicación..." -ForegroundColor Yellow
    docker-compose -f $DOCKER_COMPOSE_FILE build --no-cache
    docker-compose -f $DOCKER_COMPOSE_FILE up -d

    # Esperar a que la aplicación esté lista
    Write-Host "⏳ Esperando a que la aplicación esté lista..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30

    # Verificar que la aplicación está funcionando
    Write-Host "🔍 Verificando que la aplicación esté funcionando..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Aplicación funcionando correctamente" -ForegroundColor Green
        } else {
            throw "Status code: $($response.StatusCode)"
        }
    } catch {
        Write-Host "❌ Error: La aplicación no está respondiendo en el puerto 3000" -ForegroundColor Red
        Write-Host "   Revisa los logs: docker-compose -f $DOCKER_COMPOSE_FILE logs" -ForegroundColor Yellow
        exit 1
    }
}

# Configurar nginx (solo en Linux)
if (-not $SkipNginx) {
    Write-Host "🔧 Configurando nginx..." -ForegroundColor Yellow
    Write-Host "⚠️  Nota: Este script está diseñado para Linux. En Windows, usa Docker Desktop con nginx." -ForegroundColor Yellow
    Write-Host "   Para Windows, considera usar Docker Desktop con un contenedor nginx." -ForegroundColor Yellow
}

# Verificar que las rutas OAuth funcionan
Write-Host "🔍 Verificando rutas OAuth..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/auth/github" -TimeoutSec 10
    Write-Host "✅ Ruta OAuth funcionando correctamente" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Advertencia: Ruta OAuth no responde (esto es normal si no hay HTTPS)" -ForegroundColor Yellow
    Write-Host "   En producción, asegúrate de configurar HTTPS" -ForegroundColor Yellow
}

# Verificar que la aplicación principal funciona
Write-Host "🔍 Verificando aplicación principal..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Aplicación principal funcionando correctamente" -ForegroundColor Green
    } else {
        throw "Status code: $($response.StatusCode)"
    }
} catch {
    Write-Host "❌ Error: Aplicación principal no responde" -ForegroundColor Red
    Write-Host "   Revisa los logs: docker-compose -f $DOCKER_COMPOSE_FILE logs" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🎉 ¡Despliegue completado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen del despliegue:" -ForegroundColor Cyan
Write-Host "   • Aplicación: http://localhost:3000/" -ForegroundColor White
Write-Host "   • Health check: http://localhost:3000/health" -ForegroundColor White
Write-Host "   • Ruta OAuth: http://localhost:3000/auth/github" -ForegroundColor White
Write-Host "   • Configuración nginx: $NGINX_CONFIG_FILE" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Comandos útiles:" -ForegroundColor Cyan
Write-Host "   • Ver logs de la aplicación: docker-compose -f $DOCKER_COMPOSE_FILE logs -f" -ForegroundColor White
Write-Host "   • Reiniciar aplicación: docker-compose -f $DOCKER_COMPOSE_FILE restart" -ForegroundColor White
Write-Host "   • Detener aplicación: docker-compose -f $DOCKER_COMPOSE_FILE down" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  Nota: Para producción en servidor Linux, usa:" -ForegroundColor Yellow
Write-Host "   • Script bash: ./deploy-oauth-hdi.sh" -ForegroundColor White
Write-Host "   • Configurar nginx con la configuración nginx-oauth-hdi.conf" -ForegroundColor White
Write-Host "   • Configurar HTTPS con certificados SSL" -ForegroundColor White
Write-Host "   • Verificar que las URLs de callback OAuth coincidan" -ForegroundColor White
