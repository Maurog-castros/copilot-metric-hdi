#!/bin/bash

# Script de backup para HDI Copilot Metrics Viewer
# Realiza backup de configuraciones, logs y datos

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
BACKUP_DIR="/backup/copilot-metrics"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="copilot-metrics-backup-$DATE"

# Función para crear backup
create_backup() {
    print_header "🔄 Creando Backup de Copilot Metrics Viewer"
    
    # Crear directorio de backup
    mkdir -p "$BACKUP_DIR/$BACKUP_NAME"
    
    # Backup de configuraciones
    print_status "Respaldando configuraciones..."
    cp -r nginx/ "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || print_warning "No se encontró directorio nginx"
    cp -r monitoring/ "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || print_warning "No se encontró directorio monitoring"
    cp .env "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || print_warning "No se encontró archivo .env"
    cp docker-compose.hdi.yml "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || print_warning "No se encontró docker-compose.hdi.yml"
    cp Dockerfile.hdi "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || print_warning "No se encontró Dockerfile.hdi"
    
    # Backup de logs
    print_status "Respaldando logs..."
    if [ -d "logs" ]; then
        cp -r logs/ "$BACKUP_DIR/$BACKUP_NAME/"
    else
        print_warning "No se encontró directorio de logs"
    fi
    
    # Backup de volúmenes Docker
    print_status "Respaldando volúmenes Docker..."
    docker run --rm -v copilot-metrics_hdi_copilot-public:/data -v "$BACKUP_DIR/$BACKUP_NAME":/backup alpine tar czf /backup/copilot-public.tar.gz -C /data . 2>/dev/null || print_warning "No se pudo respaldar volumen copilot-public"
    docker run --rm -v copilot-metrics_hdi_copilot-sessions:/data -v "$BACKUP_DIR/$BACKUP_NAME":/backup alpine tar czf /backup/copilot-sessions.tar.gz -C /data . 2>/dev/null || print_warning "No se pudo respaldar volumen copilot-sessions"
    
    # Backup de base de datos Redis
    print_status "Respaldando Redis..."
    docker exec redis-copilot-metrics redis-cli BGSAVE 2>/dev/null || print_warning "No se pudo respaldar Redis"
    docker cp redis-copilot-metrics:/data/dump.rdb "$BACKUP_DIR/$BACKUP_NAME/redis-dump.rdb" 2>/dev/null || print_warning "No se pudo copiar dump de Redis"
    
    # Crear archivo de información del backup
    cat > "$BACKUP_DIR/$BACKUP_NAME/backup-info.txt" << EOF
Backup de Copilot Metrics Viewer
Fecha: $(date)
Versión: $(git describe --tags 2>/dev/null || echo "unknown")
Docker Compose: $(docker-compose --version 2>/dev/null || echo "unknown")
Sistema: $(uname -a)
EOF
    
    # Comprimir backup
    print_status "Comprimiendo backup..."
    cd "$BACKUP_DIR"
    tar czf "$BACKUP_NAME.tar.gz" "$BACKUP_NAME"
    rm -rf "$BACKUP_NAME"
    
    print_status "Backup creado exitosamente: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
    
    # Limpiar backups antiguos (mantener últimos 7 días)
    print_status "Limpiando backups antiguos..."
    find "$BACKUP_DIR" -name "copilot-metrics-backup-*.tar.gz" -mtime +7 -delete 2>/dev/null || true
    
    print_header "✅ Backup Completado"
    print_status "Archivo: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
    print_status "Tamaño: $(du -h "$BACKUP_DIR/$BACKUP_NAME.tar.gz" | cut -f1)"
}

# Función para restaurar backup
restore_backup() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        print_error "Debes especificar el archivo de backup"
        print_status "Uso: $0 restore <archivo-backup.tar.gz>"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Archivo de backup no encontrado: $backup_file"
        exit 1
    fi
    
    print_header "🔄 Restaurando Backup de Copilot Metrics Viewer"
    
    # Detener servicios
    print_status "Deteniendo servicios..."
    docker-compose -f docker-compose.hdi.yml down 2>/dev/null || true
    
    # Extraer backup
    print_status "Extrayendo backup..."
    tar xzf "$backup_file" -C /tmp/
    backup_dir="/tmp/$(basename "$backup_file" .tar.gz)"
    
    # Restaurar configuraciones
    print_status "Restaurando configuraciones..."
    cp -r "$backup_dir/nginx/" . 2>/dev/null || print_warning "No se pudo restaurar nginx"
    cp -r "$backup_dir/monitoring/" . 2>/dev/null || print_warning "No se pudo restaurar monitoring"
    cp "$backup_dir/.env" . 2>/dev/null || print_warning "No se pudo restaurar .env"
    cp "$backup_dir/docker-compose.hdi.yml" . 2>/dev/null || print_warning "No se pudo restaurar docker-compose.hdi.yml"
    cp "$backup_dir/Dockerfile.hdi" . 2>/dev/null || print_warning "No se pudo restaurar Dockerfile.hdi"
    
    # Restaurar logs
    if [ -d "$backup_dir/logs" ]; then
        print_status "Restaurando logs..."
        cp -r "$backup_dir/logs/" .
    fi
    
    # Restaurar volúmenes Docker
    print_status "Restaurando volúmenes Docker..."
    docker volume create copilot-metrics_hdi_copilot-public 2>/dev/null || true
    docker volume create copilot-metrics_hdi_copilot-sessions 2>/dev/null || true
    
    if [ -f "$backup_dir/copilot-public.tar.gz" ]; then
        docker run --rm -v copilot-metrics_hdi_copilot-public:/data -v "$backup_dir":/backup alpine tar xzf /backup/copilot-public.tar.gz -C /data
    fi
    
    if [ -f "$backup_dir/copilot-sessions.tar.gz" ]; then
        docker run --rm -v copilot-metrics_hdi_copilot-sessions:/data -v "$backup_dir":/backup alpine tar xzf /backup/copilot-sessions.tar.gz -C /data
    fi
    
    # Limpiar archivos temporales
    rm -rf "$backup_dir"
    
    print_status "Restaurando servicios..."
    docker-compose -f docker-compose.hdi.yml up -d
    
    print_header "✅ Restauración Completada"
    print_status "Los servicios se han restaurado desde el backup"
}

# Función para mostrar ayuda
show_help() {
    echo "Script de Backup para HDI Copilot Metrics Viewer"
    echo ""
    echo "Uso: $0 [comando] [opciones]"
    echo ""
    echo "Comandos:"
    echo "  backup              Crear backup completo"
    echo "  restore <archivo>   Restaurar desde backup"
    echo "  list                Listar backups disponibles"
    echo "  help                Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 backup"
    echo "  $0 restore /backup/copilot-metrics-backup-20250109_120000.tar.gz"
    echo "  $0 list"
}

# Función para listar backups
list_backups() {
    print_header "📋 Backups Disponibles"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        print_warning "Directorio de backup no existe: $BACKUP_DIR"
        return
    fi
    
    if [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        print_warning "No hay backups disponibles"
        return
    fi
    
    echo "Archivo de Backup                    Tamaño    Fecha"
    echo "=================================================="
    ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | awk '{print $9, $5, $6, $7, $8}' | while read file size date time; do
        filename=$(basename "$file")
        printf "%-40s %-8s %s %s\n" "$filename" "$size" "$date" "$time"
    done
}

# Función principal
main() {
    case "${1:-backup}" in
        "backup")
            create_backup
            ;;
        "restore")
            restore_backup "$2"
            ;;
        "list")
            list_backups
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
