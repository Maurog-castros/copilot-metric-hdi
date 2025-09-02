# Script de despliegue para HDI en PowerShell
# Este script construye y despliega la aplicación en Docker

param(
    [switch]$BuildOnly,
    [switch]$Help
)

if ($Help) {
    Write-Host "Uso: .\deploy-hdi.ps1 [-BuildOnly] [-Help]" -ForegroundColor Green
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor Yellow
    Write-Host "  -BuildOnly    Solo construir la imagen, no desplegar" -ForegroundColor White
    Write-Host "  -Help         Mostrar esta ayuda" -ForegroundColor White
    exit 0
}

Write-Host "🚀 Iniciando despliegue de Copilot Metrics Viewer para HDI..." -ForegroundColor Green

# Función para imprimir mensajes con colores
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Verificar si Docker está instalado
try {
    $dockerVersion = docker --version 2>$null
    if (-not $dockerVersion) {
        throw "Docker no está disponible"
    }
    Write-Status "Docker encontrado: $dockerVersion"
} catch {
    Write-Error "Docker no está instalado o no está ejecutándose. Por favor inicia Docker Desktop."
    exit 1
}

# Verificar si Docker está ejecutándose
try {
    docker ps >$null 2>&1
    Write-Status "Docker está ejecutándose"
} catch {
    Write-Error "Docker no está ejecutándose. Por favor inicia Docker Desktop."
    exit 1
}

# Verificar archivo .env
if (-not (Test-Path ".env")) {
    Write-Warning "Archivo .env no encontrado. Copiando desde env.hdi.example..."
    if (Test-Path "env.hdi.example") {
        Copy-Item "env.hdi.example" ".env"
        Write-Warning "Por favor edita el archivo .env con tus credenciales antes de continuar."
        Write-Warning "Presiona Enter cuando hayas configurado el archivo .env..."
        Read-Host
    } else {
        Write-Error "Archivo env.hdi.example no encontrado. Por favor crea un archivo .env manualmente."
        exit 1
    }
}

# Crear directorio de logs si no existe
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Name "logs" | Out-Null
    Write-Status "Directorio de logs creado"
}

Write-Status "Construyendo imagen Docker..."
docker build -f Dockerfile.hdi -t copilot-metrics-hdi .

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error al construir la imagen Docker"
    exit 1
}

Write-Status "Imagen Docker construida exitosamente"

if ($BuildOnly) {
    Write-Status "Modo BuildOnly activado. No se desplegará la aplicación."
    Write-Status "Para desplegar, ejecuta: docker run -d -p 3000:3000 --env-file .env copilot-metrics-hdi"
    exit 0
}

# Detener contenedores existentes
Write-Status "Deteniendo contenedores existentes..."
docker stop copilot-metrics-hdi 2>$null
docker rm copilot-metrics-hdi 2>$null

# Ejecutar contenedor
Write-Status "Iniciando aplicación..."
docker run -d --name copilot-metrics-hdi -p 3000:3000 --env-file .env copilot-metrics-hdi

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error al iniciar el contenedor"
    exit 1
}

Write-Status "Esperando que la aplicación esté lista..."
Start-Sleep -Seconds 10

# Verificar estado de la aplicación
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Status "✅ Aplicación desplegada exitosamente!"
        Write-Status "🌐 La aplicación está disponible en: http://localhost:3000"
        Write-Status "📊 Panel de métricas: http://localhost:3000"
        Write-Status "🔍 Health check: http://localhost:3000/api/health"
    }
} catch {
    Write-Warning "La aplicación puede estar aún iniciando. Verificando logs..."
    docker logs copilot-metrics-hdi --tail 20
    Write-Warning "Si hay problemas, revisa los logs con: docker logs -f copilot-metrics-hdi"
}

Write-Host ""
Write-Status "Comandos útiles:"
Write-Host "  Ver logs: docker logs -f copilot-metrics-hdi" -ForegroundColor White
Write-Host "  Detener: docker stop copilot-metrics-hdi" -ForegroundColor White
Write-Host "  Reiniciar: docker restart copilot-metrics-hdi" -ForegroundColor White
Write-Host "  Estado: docker ps" -ForegroundColor White
Write-Host "  Eliminar: docker rm -f copilot-metrics-hdi" -ForegroundColor White
