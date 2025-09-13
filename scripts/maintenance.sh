#!/bin/bash

# Script de mantenimiento para HDI Copilot Metrics Viewer
# Realiza tareas de mantenimiento, limpieza y optimización

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Configuración
LOG_DIR="./logs"
BACKUP_DIR="/backup/copilot-metrics"
MAX_LOG_SIZE="100M"
MAX_LOG_FILES=10

# Función para limpiar logs
clean_logs() {
    print_header "🧹 Limpieza de Logs"
    
    if [ ! -d "$LOG_DIR" ]; then
        print_warning "Directorio de logs no existe: $LOG_DIR"
        return
    fi
    
    # Limpiar logs antiguos
    print_status "Limpiando logs antiguos..."
    find "$LOG_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    find "$LOG_DIR" -name "*.log.*" -mtime +3 -delete 2>/dev/null || true
    
    # Rotar logs grandes
    print_status "Rotando logs grandes..."
    find "$LOG_DIR" -name "*.log" -size +$MAX_LOG_SIZE -exec mv {} {}.$(date +%Y%m%d_%H%M%S) \; 2>/dev/null || true
    
    # Limitar número de archivos de log
    print_status "Limitando archivos de log..."
    find "$LOG_DIR" -name "*.log.*" -type f | sort -r | tail -n +$((MAX_LOG_FILES + 1)) | xargs rm -f 2>/dev/null || true
    
    print_status "Limpieza de logs completada"
}

# Función para limpiar Docker
clean_docker() {
    print_header "🐳 Limpieza de Docker"
    
    # Limpiar contenedores detenidos
    print_status "Limpiando contenedores detenidos..."
    docker container prune -f 2>/dev/null || true
    
    # Limpiar imágenes no utilizadas
    print_status "Limpiando imágenes no utilizadas..."
    docker image prune -f 2>/dev/null || true
    
    # Limpiar volúmenes no utilizados
    print_status "Limpiando volúmenes no utilizados..."
    docker volume prune -f 2>/dev/null || true
    
    # Limpiar redes no utilizadas
    print_status "Limpiando redes no utilizadas..."
    docker network prune -f 2>/dev/null || true
    
    # Limpiar sistema completo
    print_status "Limpieza completa del sistema Docker..."
    docker system prune -f 2>/dev/null || true
    
    print_status "Limpieza de Docker completada"
}

# Función para verificar salud del sistema
health_check() {
    print_header "🏥 Verificación de Salud del Sistema"
    
    # Verificar Docker
    if command -v docker &> /dev/null; then
        if docker info &> /dev/null; then
            print_status "Docker: ✅ Funcionando"
        else
            print_error "Docker: ❌ No funciona"
        fi
    else
        print_error "Docker: ❌ No instalado"
    fi
    
    # Verificar servicios
    print_status "Verificando servicios..."
    
    # Verificar aplicación principal
    if curl -f http://localhost:3000/api/health &> /dev/null; then
        print_status "Aplicación: ✅ Funcionando"
    else
        print_error "Aplicación: ❌ No responde"
    fi
    
    # Verificar Nginx
    if curl -f http://localhost:80 &> /dev/null; then
        print_status "Nginx: ✅ Funcionando"
    else
        print_error "Nginx: ❌ No responde"
    fi
    
    # Verificar Redis
    if docker exec redis-copilot-metrics redis-cli ping &> /dev/null; then
        print_status "Redis: ✅ Funcionando"
    else
        print_error "Redis: ❌ No responde"
    fi
    
    # Verificar Prometheus
    if curl -f http://localhost:9090/-/healthy &> /dev/null; then
        print_status "Prometheus: ✅ Funcionando"
    else
        print_error "Prometheus: ❌ No responde"
    fi
    
    # Verificar Grafana
    if curl -f http://localhost:3001/api/health &> /dev/null; then
        print_status "Grafana: ✅ Funcionando"
    else
        print_error "Grafana: ❌ No responde"
    fi
}

# Función para actualizar dependencias
update_dependencies() {
    print_header "📦 Actualización de Dependencias"
    
    # Verificar si hay actualizaciones de Docker
    print_status "Verificando actualizaciones de Docker..."
    docker-compose -f docker-compose.hdi.yml pull 2>/dev/null || print_warning "No se pudieron verificar actualizaciones"
    
    # Reconstruir imagen de la aplicación
    print_status "Reconstruyendo imagen de la aplicación..."
    docker-compose -f docker-compose.hdi.yml build --no-cache 2>/dev/null || print_error "Error al reconstruir imagen"
    
    print_status "Actualización de dependencias completada"
}

# Función para optimizar rendimiento
optimize_performance() {
    print_header "⚡ Optimización de Rendimiento"
    
    # Optimizar base de datos Redis
    print_status "Optimizando Redis..."
    docker exec redis-copilot-metrics redis-cli BGREWRITEAOF 2>/dev/null || print_warning "No se pudo optimizar Redis"
    
    # Limpiar cache de la aplicación
    print_status "Limpiando cache de la aplicación..."
    docker exec copilot-metrics-hdi rm -rf /app/.nuxt/cache 2>/dev/null || print_warning "No se pudo limpiar cache"
    
    # Reiniciar servicios para liberar memoria
    print_status "Reiniciando servicios..."
    docker-compose -f docker-compose.hdi.yml restart 2>/dev/null || print_error "Error al reiniciar servicios"
    
    print_status "Optimización de rendimiento completada"
}

# Función para generar reporte de estado
generate_report() {
    print_header "📊 Reporte de Estado del Sistema"
    
    local report_file="system-report-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Reporte de Estado - HDI Copilot Metrics Viewer"
        echo "Fecha: $(date)"
        echo "=========================================="
        echo ""
        
        echo "=== Información del Sistema ==="
        uname -a
        echo ""
        
        echo "=== Uso de Disco ==="
        df -h
        echo ""
        
        echo "=== Uso de Memoria ==="
        free -h
        echo ""
        
        echo "=== Estado de Docker ==="
        docker system df
        echo ""
        
        echo "=== Contenedores Activos ==="
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        
        echo "=== Uso de Recursos por Contenedor ==="
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
        echo ""
        
        echo "=== Logs de Errores Recientes ==="
        docker logs copilot-metrics-hdi --tail 20 2>&1 | grep -i error || echo "No hay errores recientes"
        echo ""
        
        echo "=== Estado de Health Checks ==="
        curl -s http://localhost:3000/api/health | jq . 2>/dev/null || echo "Health check no disponible"
        echo ""
        
    } > "$report_file"
    
    print_status "Reporte generado: $report_file"
}

# Función para mostrar ayuda
show_help() {
    echo "Script de Mantenimiento para HDI Copilot Metrics Viewer"
    echo ""
    echo "Uso: $0 [comando] [opciones]"
    echo ""
    echo "Comandos:"
    echo "  clean-logs         Limpiar logs antiguos y rotar logs grandes"
    echo "  clean-docker       Limpiar contenedores, imágenes y volúmenes no utilizados"
    echo "  health-check       Verificar salud de todos los servicios"
    echo "  update-deps        Actualizar dependencias y reconstruir imágenes"
    echo "  optimize           Optimizar rendimiento del sistema"
    echo "  report             Generar reporte de estado del sistema"
    echo "  full               Ejecutar mantenimiento completo"
    echo "  help               Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 clean-logs"
    echo "  $0 health-check"
    echo "  $0 full"
}

# Función para mantenimiento completo
full_maintenance() {
    print_header "🔧 Mantenimiento Completo del Sistema"
    
    clean_logs
    clean_docker
    health_check
    update_dependencies
    optimize_performance
    generate_report
    
    print_header "✅ Mantenimiento Completo Finalizado"
    print_status "Todos los servicios han sido optimizados y verificados"
}

# Función principal
main() {
    case "${1:-help}" in
        "clean-logs")
            clean_logs
            ;;
        "clean-docker")
            clean_docker
            ;;
        "health-check")
            health_check
            ;;
        "update-deps")
            update_dependencies
            ;;
        "optimize")
            optimize_performance
            ;;
        "report")
            generate_report
            ;;
        "full")
            full_maintenance
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Comando no reconocido: $1"
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"
