# Script para desplegar ambas versiones de Copilot Metrics
# Versión sin OAuth: /copilot-metrics-viewer/
# Versión con OAuth: /copilot-metrics-viewer-hdi/

Write-Host "=== Desplegando ambas versiones de Copilot Metrics ===" -ForegroundColor Green

# 1. Construir la imagen
Write-Host "1. Construyendo imagen Docker..." -ForegroundColor Yellow
docker build -t copilot-metrics-hdi .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al construir la imagen Docker" -ForegroundColor Red
    exit 1
}

# 2. Parar servicios existentes
Write-Host "2. Parando servicios existentes..." -ForegroundColor Yellow
docker compose down

# 3. Crear directorios de logs si no existen
Write-Host "3. Creando directorios de logs..." -ForegroundColor Yellow
if (!(Test-Path "nginx/logs")) {
    New-Item -ItemType Directory -Path "nginx/logs" -Force
}

# 4. Iniciar servicios
Write-Host "4. Iniciando servicios..." -ForegroundColor Yellow
docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al iniciar los servicios" -ForegroundColor Red
    exit 1
}

# 5. Verificar estado de los servicios
Write-Host "5. Verificando estado de los servicios..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
docker compose ps

# 6. Mostrar logs
Write-Host "6. Mostrando logs de los servicios..." -ForegroundColor Yellow
Write-Host "`n=== LOGS DE SERVICIOS ===" -ForegroundColor Cyan
docker compose logs --tail=20

Write-Host "`n=== DESPLIEGUE COMPLETADO ===" -ForegroundColor Green
Write-Host "Versión sin OAuth: http://vskpip01.hdi.chile/copilot-metrics-viewer/" -ForegroundColor Cyan
Write-Host "Versión con OAuth: http://vskpip01.hdi.chile/copilot-metrics-viewer-hdi/" -ForegroundColor Cyan
Write-Host "`nPara ver logs en tiempo real: docker compose logs -f" -ForegroundColor Yellow
Write-Host "Para parar servicios: docker compose down" -ForegroundColor Yellow
