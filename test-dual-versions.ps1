# Script para probar ambas versiones de Copilot Metrics

Write-Host "=== Probando ambas versiones de Copilot Metrics ===" -ForegroundColor Green

$baseUrl = "http://vskpip01.hdi.chile"
$noAuthUrl = "$baseUrl/copilot-metrics-viewer/"
$oauthUrl = "$baseUrl/copilot-metrics-viewer-hdi/"

# Función para probar una URL
function Test-Url {
    param(
        [string]$Url,
        [string]$Description
    )
    
    Write-Host "`nProbando: $Description" -ForegroundColor Yellow
    Write-Host "URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 30
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ OK - Status: $($response.StatusCode)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Error - Status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Error - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Función para probar API
function Test-Api {
    param(
        [string]$ApiUrl,
        [string]$Description
    )
    
    Write-Host "`nProbando API: $Description" -ForegroundColor Yellow
    Write-Host "URL: $ApiUrl" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $ApiUrl -Method GET -TimeoutSec 30
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401) {
            Write-Host "✓ OK - Status: $($response.StatusCode)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Error - Status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Error - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Verificar que los contenedores estén corriendo
Write-Host "`n=== Verificando contenedores ===" -ForegroundColor Cyan
docker compose ps

# Probar versión sin OAuth
Write-Host "`n=== PROBANDO VERSIÓN SIN OAUTH ===" -ForegroundColor Cyan
$noAuthMain = Test-Url -Url $noAuthUrl -Description "Página principal sin OAuth"
$noAuthApi = Test-Api -ApiUrl "$noAuthUrl/api/health" -Description "API Health sin OAuth"

# Probar versión con OAuth
Write-Host "`n=== PROBANDO VERSIÓN CON OAUTH ===" -ForegroundColor Cyan
$oauthMain = Test-Url -Url $oauthUrl -Description "Página principal con OAuth"
$oauthApi = Test-Api -ApiUrl "$oauthUrl/api/health" -Description "API Health con OAuth"
$oauthAuth = Test-Api -ApiUrl "$oauthUrl/api/_auth/session" -Description "API Auth Session con OAuth"

# Resumen de resultados
Write-Host "`n=== RESUMEN DE PRUEBAS ===" -ForegroundColor Green
Write-Host "Versión sin OAuth:" -ForegroundColor Yellow
Write-Host "  Página principal: $(if($noAuthMain) {'✓ OK'} else {'✗ FALLO'})" -ForegroundColor $(if($noAuthMain) {'Green'} else {'Red'})
Write-Host "  API Health: $(if($noAuthApi) {'✓ OK'} else {'✗ FALLO'})" -ForegroundColor $(if($noAuthApi) {'Green'} else {'Red'})

Write-Host "`nVersión con OAuth:" -ForegroundColor Yellow
Write-Host "  Página principal: $(if($oauthMain) {'✓ OK'} else {'✗ FALLO'})" -ForegroundColor $(if($oauthMain) {'Green'} else {'Red'})
Write-Host "  API Health: $(if($oauthApi) {'✓ OK'} else {'✗ FALLO'})" -ForegroundColor $(if($oauthApi) {'Green'} else {'Red'})
Write-Host "  API Auth Session: $(if($oauthAuth) {'✓ OK'} else {'✗ FALLO'})" -ForegroundColor $(if($oauthAuth) {'Green'} else {'Red'})

# Verificar logs si hay errores
if (-not ($noAuthMain -and $noAuthApi -and $oauthMain -and $oauthApi)) {
    Write-Host "`n=== REVISANDO LOGS POR ERRORES ===" -ForegroundColor Red
    Write-Host "Logs de servicios:" -ForegroundColor Yellow
    docker compose logs --tail=10
}

Write-Host "`n=== PRUEBAS COMPLETADAS ===" -ForegroundColor Green
