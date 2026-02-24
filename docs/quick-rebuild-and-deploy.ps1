# Script para rebuild rápido y despliegue
# quick-rebuild-and-deploy.ps1
param(
    [string]$ServerIP = "192.168.1.24",
    [string]$ServerUser = "mcastro",
    [string]$ServerPath = "/home/Apps/CopilotMetrics"
)

Write-Host "🔧 Rebuild rápido y despliegue..." -ForegroundColor Green

# Paso 1: Limpiar build anterior
Write-Host "🧹 Limpiando build anterior..." -ForegroundColor Yellow
Remove-Item -Recurse -Force .nuxt -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .output -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue

# Paso 2: Rebuild
Write-Host "🔨 Reconstruyendo aplicación..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error en el build" -ForegroundColor Red
    exit 1
}

# Paso 3: Buscar imagen anterior para limpiar
$oldImages = Get-ChildItem -Path "." -Filter "copilot-metrics-image-*.tar" | Sort-Object LastWriteTime -Descending
if ($oldImages.Count -gt 1) {
    Write-Host "🗑️ Limpiando imágenes anteriores..." -ForegroundColor Yellow
    for ($i = 1; $i -lt $oldImages.Count; $i++) {
        Remove-Item $oldImages[$i].FullName -Force
        Write-Host "   Eliminado: $($oldImages[$i].Name)" -ForegroundColor Gray
    }
}

# Paso 4: Construir nueva imagen
Write-Host "🐳 Construyendo nueva imagen Docker..." -ForegroundColor Yellow
docker build -f Dockerfile.production -t copilot-metrics-hdi:latest .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error construyendo imagen Docker" -ForegroundColor Red
    exit 1
}

# Paso 5: Guardar imagen
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$imageFile = "copilot-metrics-image-${timestamp}.tar"
Write-Host "💾 Guardando imagen como: $imageFile" -ForegroundColor Yellow
docker save copilot-metrics-hdi:latest -o $imageFile

# Paso 6: Desplegar
Write-Host "🚀 Desplegando en servidor..." -ForegroundColor Yellow
.\deploy-complete.ps1 -ServerIP $ServerIP -ServerUser $ServerUser -ServerPath $ServerPath

Write-Host "✅ Rebuild y despliegue completado!" -ForegroundColor Green
