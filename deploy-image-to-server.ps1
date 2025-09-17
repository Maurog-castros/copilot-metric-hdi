# Script para subir la imagen al servidor
# deploy-image-to-server.ps1
param(
    [string]$ServerIP = "192.168.1.24",
    [string]$ServerUser = "mcastro",
    [string]$ServerPath = "/home/Apps/CopilotMetrics"
)

Write-Host "🚀 Subiendo imagen al servidor..." -ForegroundColor Green

# Buscar el archivo de imagen más reciente
$imageFiles = Get-ChildItem -Path "." -Filter "copilot-metrics-image-*.tar" | Sort-Object LastWriteTime -Descending

if ($imageFiles.Count -eq 0) {
    Write-Host "❌ Error: No se encontraron archivos de imagen" -ForegroundColor Red
    exit 1
}

$latestImageFile = $imageFiles[0].Name
Write-Host "📦 Usando imagen: $latestImageFile" -ForegroundColor Yellow

# Paso 1: Copiar imagen al servidor
Write-Host "📤 Copiando imagen al servidor..." -ForegroundColor Yellow
scp $latestImageFile "${ServerUser}@${ServerIP}:${ServerPath}/"

# Paso 2: Cargar imagen en el servidor
Write-Host "🐳 Cargando imagen en el servidor..." -ForegroundColor Yellow
ssh "${ServerUser}@${ServerIP}" @"
cd ${ServerPath}
echo 'Cargando imagen Docker...'
docker load -i $latestImageFile
echo 'Verificando imagen cargada...'
docker images copilot-metrics-hdi:latest
echo 'Limpiando archivo temporal...'
rm $latestImageFile
echo 'Imagen cargada exitosamente!'
"@

Write-Host "✅ Imagen desplegada exitosamente!" -ForegroundColor Green