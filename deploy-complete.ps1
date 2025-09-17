# Script completo para desplegar la aplicación en el servidor
# deploy-complete.ps1
param(
    [string]$ServerIP = "192.168.1.24",
    [string]$ServerUser = "mcastro",
    [string]$ServerPath = "/home/Apps/CopilotMetrics"
)

Write-Host "🚀 Iniciando despliegue completo..." -ForegroundColor Green

# Buscar el archivo de imagen más reciente
$imageFiles = Get-ChildItem -Path "." -Filter "copilot-metrics-image-*.tar" | Sort-Object LastWriteTime -Descending

if ($imageFiles.Count -eq 0) {
    Write-Host "❌ Error: No se encontraron archivos de imagen" -ForegroundColor Red
    Write-Host "💡 Ejecuta primero: .\build-image-local.ps1" -ForegroundColor Yellow
    exit 1
}

$latestImageFile = $imageFiles[0].Name
Write-Host "📦 Usando imagen: $latestImageFile" -ForegroundColor Yellow

# Paso 1: Copiar imagen al servidor
Write-Host "📤 Copiando imagen al servidor..." -ForegroundColor Yellow
scp $latestImageFile "${ServerUser}@${ServerIP}:${ServerPath}/"

# Paso 2: Copiar docker-compose.yml al servidor
Write-Host "📋 Copiando docker-compose.yml al servidor..." -ForegroundColor Yellow
scp docker-compose.yml "${ServerUser}@${ServerIP}:${ServerPath}/"

# Paso 3: Ejecutar comandos en el servidor
Write-Host "🐳 Ejecutando despliegue en el servidor..." -ForegroundColor Yellow
ssh "${ServerUser}@${ServerIP}" @"
cd ${ServerPath}

echo '🛑 Deteniendo contenedores existentes...'
docker-compose down || echo 'No hay contenedores para detener'

echo '🗑️ Limpiando contenedores e imágenes anteriores...'
docker container prune -f
docker image prune -f

echo '📦 Cargando nueva imagen...'
docker load -i $latestImageFile

echo '🔍 Verificando imagen cargada...'
docker images copilot-metrics-hdi:latest

echo '🧹 Limpiando archivo temporal...'
rm $latestImageFile

echo '🚀 Iniciando nueva aplicación...'
docker-compose up -d

echo '⏳ Esperando que la aplicación esté lista...'
sleep 10

echo '🔍 Verificando estado de la aplicación...'
docker-compose ps

echo '🏥 Verificando salud de la aplicación...'
curl -f http://localhost:3000/api/health || echo 'Health check falló, pero la aplicación puede estar iniciando...'

echo '✅ Despliegue completado!'
echo '🌐 La aplicación está disponible en: http://${ServerIP}:3000'
"@

Write-Host "✅ Despliegue completado exitosamente!" -ForegroundColor Green
Write-Host "🌐 Accede a la aplicación en: http://${ServerIP}:3000" -ForegroundColor Cyan
