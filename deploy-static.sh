#!/bin/bash

# Script para desplegar build estática de Copilot Metrics Viewer en servidor HDI
# Uso: ./deploy-static.sh [servidor] [usuario]

set -e

# Configuración por defecto
SERVER=${1:-"192.168.1.24"}
USER=${2:-"mcastro"}
APP_NAME="copilot-metrics"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
WEB_ROOT="/var/www/$APP_NAME"

echo "🚀 Desplegando Copilot Metrics Viewer en servidor estático..."
echo "📡 Servidor: $SERVER"
echo "👤 Usuario: $USER"
echo "📁 Directorio web: $WEB_ROOT"

# Verificar que existe la build
if [ ! -d ".output/public" ]; then
    echo "❌ Error: No se encontró la build en .output/public"
    echo "💡 Ejecuta primero: npm run build"
    exit 1
fi

echo "✅ Build encontrada en .output/public"

# Crear archivo temporal con la configuración de nginx
cat > nginx-static-temp.conf << 'EOF'
# Configuración de Nginx para servir build estática de Copilot Metrics Viewer
server {
    listen 80;
    server_name localhost;
    
    root /var/www/copilot-metrics/public;
    index index.html;
    
    # Logs
    access_log /var/log/nginx/copilot-metrics-static.access.log;
    error_log /var/log/nginx/copilot-metrics-static.error.log;
    
    # Configuración de seguridad
    server_tokens off;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Configuración de compresión
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    # Configuración de caché para archivos estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Archivos HTML con caché corto
    location ~* \.html$ {
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
    }
    
    # Configuración para SPA
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Favicon
    location /favicon.ico {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Robots.txt
    location /robots.txt {
        expires 1d;
        add_header Cache-Control "public";
    }
}
EOF

echo "📤 Subiendo archivos al servidor..."

# Crear directorio en el servidor y subir archivos
sshpass -p "HDI.2025" ssh -o StrictHostKeyChecking=no $USER@$SERVER << EOF
    echo "🔧 Configurando directorio web..."
    sudo mkdir -p $WEB_ROOT
    sudo chown -R www-data:www-data $WEB_ROOT
    sudo chmod -R 755 $WEB_ROOT
EOF

# Subir archivos de la build
echo "📁 Copiando archivos de la build..."
sshpass -p "HDI.2025" scp -r -o StrictHostKeyChecking=no .output/public/* $USER@$SERVER:/tmp/copilot-build/

# Mover archivos al directorio web
sshpass -p "HDI.2025" ssh -o StrictHostKeyChecking=no $USER@$SERVER << EOF
    echo "📂 Moviendo archivos al directorio web..."
    sudo rm -rf $WEB_ROOT/*
    sudo mv /tmp/copilot-build/* $WEB_ROOT/
    sudo chown -R www-data:www-data $WEB_ROOT
    sudo chmod -R 755 $WEB_ROOT
    rm -rf /tmp/copilot-build
EOF

echo "⚙️ Configurando Nginx..."

# Subir configuración de nginx
sshpass -p "HDI.2025" scp -o StrictHostKeyChecking=no nginx-static-temp.conf $USER@$SERVER:/tmp/nginx-static.conf

# Configurar nginx en el servidor
sshpass -p "HDI.2025" ssh -o StrictHostKeyChecking=no $USER@$SERVER << EOF
    echo "🔧 Configurando Nginx..."
    
    # Copiar configuración
    sudo cp /tmp/nginx-static.conf $NGINX_SITES_AVAILABLE/$APP_NAME
    
    # Crear enlace simbólico
    sudo ln -sf $NGINX_SITES_AVAILABLE/$APP_NAME $NGINX_SITES_ENABLED/
    
    # Verificar configuración
    sudo nginx -t
    
    if [ \$? -eq 0 ]; then
        echo "✅ Configuración de Nginx válida"
        # Recargar nginx
        sudo systemctl reload nginx
        echo "🔄 Nginx recargado"
    else
        echo "❌ Error en configuración de Nginx"
        exit 1
    fi
    
    # Limpiar archivo temporal
    rm /tmp/nginx-static.conf
EOF

# Limpiar archivo temporal local
rm nginx-static-temp.conf

echo "🎉 ¡Despliegue completado!"
echo "🌐 La aplicación está disponible en: http://$SERVER"
echo "🔍 Health check: http://$SERVER/health"

# Verificar que el servicio está funcionando
echo "🔍 Verificando estado del servicio..."
sshpass -p "HDI.2025" ssh -o StrictHostKeyChecking=no $USER@$SERVER << EOF
    echo "📊 Estado de Nginx:"
    sudo systemctl status nginx --no-pager -l
    
    echo ""
    echo "🔗 Enlaces de configuración:"
    ls -la $NGINX_SITES_ENABLED/ | grep $APP_NAME || echo "No se encontró enlace"
    
    echo ""
    echo "📁 Archivos desplegados:"
    ls -la $WEB_ROOT/ | head -10
EOF

echo ""
echo "✅ Despliegue estático completado exitosamente!"
echo "💡 Para actualizar la aplicación, simplemente ejecuta este script nuevamente después de hacer 'npm run build'"
