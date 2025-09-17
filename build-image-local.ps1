param(
    [string]$ImageTag = "copilot-metrics-hdi:latest",
    [string]$OutputPrefix = "copilot-metrics-image"
)

Write-Host "🐳 Construyendo imagen Docker local..." -ForegroundColor Green

# Paso 1: Limpiar builds anteriores
Write-Host "🧹 Limpiando builds anteriores..." -ForegroundColor Yellow
Remove-Item -Recurse -Force .output -ErrorAction SilentlyContinue

# Paso 2: Instalar dependencias
Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
npm ci

# Paso 3: Generar build completo (no solo estático)
Write-Host "⚙️ Generando build completo..." -ForegroundColor Yellow
npm run build

# Paso 4: Verificar que se generó correctamente
if (Test-Path ".output") {
    Write-Host "✅ Build generado correctamente" -ForegroundColor Green
    
    # Paso 5: Verificar estructura
    Write-Host "🔍 Verificando estructura de build..." -ForegroundColor Yellow
    if (Test-Path ".output/server") {
        Write-Host "✅ Servidor encontrado" -ForegroundColor Green
    }
    if (Test-Path ".output/public") {
        Write-Host "✅ Archivos públicos encontrados" -ForegroundColor Green
    }
    
    # Paso 6: Construir imagen Docker
    Write-Host "🐳 Construyendo imagen Docker..." -ForegroundColor Yellow
    docker build -f Dockerfile.production -t $ImageTag .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Imagen construida exitosamente: $ImageTag" -ForegroundColor Green
        
        # Paso 7: Mostrar información de la imagen
        Write-Host "📊 Información de la imagen:" -ForegroundColor Cyan
        docker images $ImageTag
        
        # Paso 8: Guardar imagen como archivo tar
        Write-Host "💾 Guardando imagen como archivo..." -ForegroundColor Yellow
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $tarFile = "$OutputPrefix-$timestamp.tar"
        docker save -o $tarFile $ImageTag
        
        Write-Host "🎉 Proceso completado!" -ForegroundColor Green
        Write-Host "📦 Imagen guardada como: $tarFile" -ForegroundColor Cyan
        Write-Host "📏 Tamaño del archivo: $((Get-Item $tarFile).Length / 1MB) MB" -ForegroundColor Cyan
        
    } else {
        Write-Host "❌ Error construyendo imagen Docker" -ForegroundColor Red
        exit 1
    }
    
} else {
    Write-Host "❌ Error: No se pudo generar el build" -ForegroundColor Red
    exit 1
}
