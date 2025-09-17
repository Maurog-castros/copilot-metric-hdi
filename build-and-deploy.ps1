param(
    [string]$ImageTag = "copilot-metrics-hdi:latest",
    [string]$OutputPrefix = "copilot-metrics-image",
    [string]$ServerIP = "192.168.1.24",
    [string]$ServerUser = "mcastro",
    [string]$ServerPath = "/home/Apps/CopilotMetrics"
)

Write-Host "🚀 Iniciando build y despliegue de la imagen..." -ForegroundColor Green

# Paso 1: Limpiar builds anteriores
Write-Host "🧹 Limpiando builds anteriores..." -ForegroundColor Yellow
Remove-Item -Recurse -Force .output -ErrorAction SilentlyContinue

# Paso 2: Instalar dependencias
Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
npm ci
if ($LASTEXITCODE -ne 0) { exit 1 }

# Paso 3: Generar build completo
Write-Host "⚙️ Generando build completo..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) { exit 1 }

# Paso 4: Verificar que se generó correctamente
if (-not (Test-Path ".output")) {
    Write-Host "❌ Error: No se pudo generar el build" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build generado correctamente" -ForegroundColor Green

# Paso 5: Construir imagen Docker
Write-Host "🐳 Construyendo imagen Docker..." -ForegroundColor Yellow
docker build -f Dockerfile.production -t $ImageTag .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error construyendo imagen Docker" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Imagen construida exitosamente: $ImageTag" -ForegroundColor Green

# Paso 6: Exportar a archivo tar
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$tarFile = "$OutputPrefix-$timestamp.tar"
docker save -o $tarFile $ImageTag
Write-Host "📦 Imagen guardada como: $tarFile" -ForegroundColor Cyan
Write-Host "📏 Tamaño: $((Get-Item $tarFile).Length / 1MB) MB" -ForegroundColor Cyan

# Paso 7: Copiar al servidor
Write-Host "📤 Copiando imagen al servidor..." -ForegroundColor Yellow
scp $tarFile "${ServerUser}@${ServerIP}:${ServerPath}/"
if ($LASTEXITCODE -ne 0) { exit 1 }

# Paso 8: Cargar imagen, limpiar y reiniciar stack en el servidor
Write-Host "🐳 Cargando y desplegando imagen en el servidor..." -ForegroundColor Yellow
ssh "${ServerUser}@${ServerIP}" @"
cd ${ServerPath}
echo '📦 Cargando imagen nueva...'
docker load -i $tarFile

echo '🧹 Eliminando archivo temporal y limpiando imágenes viejas...'
rm $tarFile
docker image prune -f
docker images | grep copilot-metrics-hdi | grep -v latest | awk '{print \$3}' | xargs -r docker rmi -f

echo '🔄 Reiniciando stack con Docker Compose...'
docker compose down
docker compose up -d

echo '✅ Despliegue completado en el servidor!'
"@

if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "🎉 Proceso completado: imagen construida, desplegada y stack reiniciado!" -ForegroundColor Green
