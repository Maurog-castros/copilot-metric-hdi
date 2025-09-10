#!/bin/bash
 
# Script de instalación rápida para HDI en Linux
# Este script instala Docker y despliega la aplicación automáticamente
 
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
 
# Función para detectar distribución Linux
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/SuSe-release ]; then
        OS=SuSE
    elif [ -f /etc/redhat-release ]; then
        OS=RedHat
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    echo "$OS"
}
 
# Función para instalar Docker según la distribución
install_docker() {
    local distro=$1
   
    print_status "Instalando Docker en $distro..."
   
    case $distro in
        *Ubuntu*|*Debian*)
            # Actualizar repositorios
            sudo apt update
           
            # Instalar dependencias
            sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
           
            # Agregar GPG key oficial de Docker
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
           
            # Agregar repositorio de Docker
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
           
            # Instalar Docker
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
           
            # Iniciar y habilitar Docker
            sudo systemctl start docker
            sudo systemctl enable docker
            ;;
           
        *CentOS*|*RedHat*|*Fedora*)
            # Instalar dependencias
            sudo yum install -y yum-utils
           
            # Agregar repositorio de Docker
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
           
            # Instalar Docker
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
           
            # Iniciar y habilitar Docker
            sudo systemctl start docker
            sudo systemctl enable docker
            ;;
           
        *)
            print_error "Distribución no soportada: $distro"
            print_status "Por favor instala Docker manualmente: https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac
   
    # Agregar usuario al grupo docker
    sudo usermod -aG docker $USER
   
    print_status "Docker instalado exitosamente"
    print_warning "Reinicia la sesión o ejecuta: newgrp docker"
}
 
# Función principal
main() {
    print_header "🚀 Instalación Automática de Copilot Metrics Viewer para HDI"
   
    # Verificar si se ejecuta como root
    if [ "$EUID" -eq 0 ]; then
        print_error "No ejecutes este script como root"
        exit 1
    fi
   
    # Verificar si Docker ya está instalado
    if command -v docker &> /dev/null; then
        print_status "Docker ya está instalado: $(docker --version)"
    else
        print_header "🐳 Instalando Docker"
       
        # Detectar distribución
        DISTRO=$(detect_distro)
        print_status "Distribución detectada: $DISTRO"
       
        # Instalar Docker
        install_docker "$DISTRO"
       
        # Verificar instalación
        if ! docker info &> /dev/null; then
            print_error "Docker no se pudo iniciar. Reinicia la sesión y ejecuta: newgrp docker"
            exit 1
        fi
    fi
   
    # Verificar si el script de despliegue existe
    if [ ! -f "deploy-hdi.sh" ]; then
        print_error "Script deploy-hdi.sh no encontrado"
        print_status "Asegúrate de estar en el directorio correcto del proyecto"
        exit 1
    fi
   
    # Dar permisos de ejecución
    chmod +x deploy-hdi.sh
   
    print_header "✅ Instalación Completada"
    print_status "Docker está instalado y configurado"
    print_status "Ahora puedes ejecutar el despliegue con:"
    echo ""
    echo -e "${GREEN}./deploy-hdi.sh${NC}                    # Despliegue completo"
    echo -e "${GREEN}./deploy-hdi.sh --help${NC}             # Ver opciones disponibles"
    echo -e "${GREEN}./deploy-hdi.sh --build-only${NC}       # Solo construir imagen"
    echo ""
    print_status "Antes de desplegar, configura el archivo .env con tus credenciales:"
    echo -e "${GREEN}cp env.hdi.example .env${NC}"
    echo -e "${GREEN}nano .env${NC}"
    echo ""
    print_status "¡La instalación está lista! 🎉"
}
 
# Ejecutar función principal
main "$@"
