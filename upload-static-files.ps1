# Script para subir archivos estáticos de Copilot Metrics Viewer al servidor HDI
# Uso: .\upload-static-files.ps1

param(
    [string]$Server = "192.168.1.24",
    [string]$User = "mcastro",
    [string]$Password = "HDI.2025"
)

Write-Host "🚀 Subiendo archivos estáticos de Copilot Metrics Viewer..." -ForegroundColor Green
Write-Host "📡 Servidor: $Server" -ForegroundColor Cyan
Write-Host "👤 Usuario: $User" -ForegroundColor Cyan

# Verificar que existe la build
if (-not (Test-Path ".output\public")) {
    Write-Host "❌ Error: No se encontró la build en .output/public" -ForegroundColor Red
    Write-Host "💡 Ejecuta primero: npm run build" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Build encontrada en .output/public" -ForegroundColor Green

# Crear archivo temporal con los archivos
$tempZip = "copilot-build-temp.zip"
Write-Host "📦 Creando archivo comprimido..." -ForegroundColor Yellow

try {
    # Limpiar archivo anterior si existe
    if (Test-Path $tempZip) {
        Remove-Item $tempZip -Force
    }
    
    # Crear archivo comprimido
    Compress-Archive -Path ".output\public\*" -DestinationPath $tempZip -Force
    Write-Host "✅ Archivo comprimido creado: $tempZip" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error creando archivo comprimido: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Función para ejecutar comandos SSH
function Invoke-SSHCommand {
    param([string]$Command)
    
    $sshCommand = "ssh -o StrictHostKeyChecking=no $User@$Server `"$Command`""
    Write-Host "🔧 Ejecutando: $Command" -ForegroundColor Gray
    
    try {
        $result = Invoke-Expression $sshCommand
        return $result
    }
    catch {
        Write-Host "❌ Error ejecutando comando SSH: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Función para subir archivo con SCP
function Copy-FileToServer {
    param([string]$LocalPath, [string]$RemotePath)
    
    $scpCommand = "scp -o StrictHostKeyChecking=no `"$LocalPath`" $User@$Server`:$RemotePath"
    Write-Host "📤 Subiendo archivo..." -ForegroundColor Yellow
    
    try {
        Invoke-Expression $scpCommand
        Write-Host "✅ Archivo subido exitosamente" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Error subiendo archivo: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "📤 Subiendo archivo al servidor..." -ForegroundColor Yellow

# Subir archivo comprimido
if (-not (Copy-FileToServer $tempZip "/tmp/copilot-build.zip")) {
    Write-Host "❌ Error subiendo archivo. Verifica la conexión SSH." -ForegroundColor Red
    exit 1
}

Write-Host "🔧 Extrayendo archivos en el servidor..." -ForegroundColor Yellow

# Comandos para ejecutar en el servidor
$serverCommands = @(
    "cd /home/Apps/statics/copilot-metrics/public",
    "sudo rm -rf *",
    "cd /tmp",
    "sudo unzip -o copilot-build.zip -d /home/Apps/statics/copilot-metrics/public/",
    "sudo chown -R mcastro:mcastro /home/Apps/statics/copilot-metrics/",
    "sudo chmod -R 755 /home/Apps/statics/copilot-metrics/",
    "rm copilot-build.zip"
)

foreach ($cmd in $serverCommands) {
    $result = Invoke-SSHCommand $cmd
    if ($result -eq $null) {
        Write-Host "❌ Error ejecutando comando en servidor: $cmd" -ForegroundColor Red
        exit 1
    }
}

Write-Host "🚀 Levantando nginx reverse proxy..." -ForegroundColor Yellow

# Levantar nginx reverse proxy
$nginxCommands = @(
    "cd /home/Apps/nginxReverseProxy",
    "docker-compose down",
    "docker-compose up -d"
)

foreach ($cmd in $nginxCommands) {
    $result = Invoke-SSHCommand $cmd
    if ($result -eq $null) {
        Write-Host "❌ Error ejecutando comando nginx: $cmd" -ForegroundColor Red
        exit 1
    }
}

Write-Host "🔍 Verificando estado del servicio..." -ForegroundColor Yellow

# Verificar estado
$statusCommands = @(
    "docker ps | grep nginx",
    "ls -la /home/Apps/statics/copilot-metrics/public/ | head -10"
)

foreach ($cmd in $statusCommands) {
    Write-Host "📊 Ejecutando: $cmd" -ForegroundColor Gray
    $result = Invoke-SSHCommand $cmd
    if ($result) {
        Write-Host $result -ForegroundColor White
    }
}

# Limpiar archivo temporal local
if (Test-Path $tempZip) {
    Remove-Item $tempZip -Force
    Write-Host "🧹 Archivo temporal limpiado" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🎉 ¡Despliegue completado!" -ForegroundColor Green
Write-Host "🌐 La aplicación está disponible en: http://$Server" -ForegroundColor Cyan
Write-Host "🔍 Health check: http://$Server/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Para actualizar la aplicación, simplemente ejecuta este script nuevamente después de hacer 'npm run build'" -ForegroundColor Yellow
