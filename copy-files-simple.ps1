# Script simple para copiar archivos estáticos al servidor
# Uso: .\copy-files-simple.ps1

Write-Host "🚀 Copiando archivos estáticos de Copilot Metrics Viewer..." -ForegroundColor Green

# Verificar que existe la build
if (-not (Test-Path ".output\public")) {
    Write-Host "❌ Error: No se encontró la build en .output/public" -ForegroundColor Red
    Write-Host "💡 Ejecuta primero: npm run build" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Build encontrada en .output/public" -ForegroundColor Green

# Crear archivo comprimido
$zipFile = "copilot-build.zip"
Write-Host "📦 Creando archivo comprimido..." -ForegroundColor Yellow

if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

Compress-Archive -Path ".output\public\*" -DestinationPath $zipFile -Force
Write-Host "✅ Archivo comprimido creado: $zipFile" -ForegroundColor Green

Write-Host ""
Write-Host "📋 INSTRUCCIONES MANUALES:" -ForegroundColor Cyan
Write-Host "1. Abre WinSCP, FileZilla o cualquier cliente SFTP" -ForegroundColor White
Write-Host "2. Conéctate a: 192.168.1.24" -ForegroundColor White
Write-Host "   Usuario: mcastro" -ForegroundColor White
Write-Host "   Contraseña: HDI.2025" -ForegroundColor White
Write-Host "3. Sube el archivo: $zipFile" -ForegroundColor White
Write-Host "4. Colócalo en: /tmp/copilot-build.zip" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Luego ejecuta estos comandos en el servidor:" -ForegroundColor Yellow
Write-Host "ssh mcastro@192.168.1.24" -ForegroundColor Gray
Write-Host "cd /home/Apps/statics/copilot-metrics/public" -ForegroundColor Gray
Write-Host "sudo rm -rf *" -ForegroundColor Gray
Write-Host "cd /tmp" -ForegroundColor Gray
Write-Host "sudo unzip -o copilot-build.zip -d /home/Apps/statics/copilot-metrics/public/" -ForegroundColor Gray
Write-Host "sudo chown -R mcastro:mcastro /home/Apps/statics/copilot-metrics/" -ForegroundColor Gray
Write-Host "sudo chmod -R 755 /home/Apps/statics/copilot-metrics/" -ForegroundColor Gray
Write-Host "rm copilot-build.zip" -ForegroundColor Gray
Write-Host "cd /home/Apps/nginxReverseProxy" -ForegroundColor Gray
Write-Host "docker-compose up -d" -ForegroundColor Gray
Write-Host ""
Write-Host "🌐 Después de completar los pasos, la app estará en: http://192.168.1.24" -ForegroundColor Green
