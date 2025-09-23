# Copilot Metrics - Versiones Duales

Este proyecto ahora soporta dos versiones simultáneas de Copilot Metrics:

## 🚀 Versiones Disponibles

### 1. Versión sin OAuth (Token Fijo)
- **URL**: `http://vskpip01.hdi.chile/copilot-metrics-viewer/`
- **Autenticación**: Personal Access Token (PAT) fijo
- **Uso**: Para entornos internos o cuando no se requiere autenticación de usuario
- **Configuración**: `env.noauth`

### 2. Versión con OAuth GitHub
- **URL**: `http://vskpip01.hdi.chile/copilot-metrics-viewer-hdi/`
- **Autenticación**: GitHub OAuth (login con GitHub)
- **Uso**: Para entornos donde se requiere autenticación de usuario
- **Configuración**: `env.oauth`

## 📋 Requisitos Previos

- Docker y Docker Compose instalados
- Acceso al servidor VSKPIP01
- Configuración de GitHub OAuth App (para la versión con OAuth)

## 🛠️ Configuración

### Variables de Entorno

#### Versión sin OAuth (`env.noauth`)
```bash
NUXT_PUBLIC_USING_GITHUB_AUTH=false
NUXT_GITHUB_TOKEN=tu_personal_access_token
NUXT_PUBLIC_SCOPE=organization
NUXT_PUBLIC_GITHUB_ORG=hdicl
```

#### Versión con OAuth (`env.oauth`)
```bash
NUXT_PUBLIC_USING_GITHUB_AUTH=true
NUXT_OAUTH_GITHUB_CLIENT_ID=tu_client_id
NUXT_OAUTH_GITHUB_CLIENT_SECRET=tu_client_secret
NUXT_OAUTH_GITHUB_CLIENT_SCOPE=read:org,read:user
```

## 🚀 Despliegue

### Opción 1: Script Automatizado (Recomendado)
```powershell
.\deploy-dual-versions.ps1
```

### Opción 2: Comandos Manuales
```bash
# 1. Construir imagen
docker build -t copilot-metrics-hdi .

# 2. Parar servicios existentes
docker compose down

# 3. Iniciar servicios
docker compose up -d

# 4. Verificar estado
docker compose ps
```

## 🧪 Pruebas

### Script de Pruebas Automatizado
```powershell
.\test-dual-versions.ps1
```

### Pruebas Manuales
1. **Versión sin OAuth**: http://vskpip01.hdi.chile/copilot-metrics-viewer/
2. **Versión con OAuth**: http://vskpip01.hdi.chile/copilot-metrics-viewer-hdi/

## 📊 Monitoreo

### Ver Logs
```bash
# Todos los servicios
docker compose logs -f

# Servicio específico
docker compose logs -f copilot-metrics-viewer
docker compose logs -f copilot-metrics-viewer-hdi
```

### Logs de Nginx
```bash
# Acceso general
docker exec reverse-proxy cat /var/log/nginx/copilot_access.log

# Acceso sin OAuth
docker exec reverse-proxy cat /var/log/nginx/copilot_noauth_access.log

# Acceso con OAuth
docker exec reverse-proxy cat /var/log/nginx/copilot_oauth_access.log
```

## 🔧 Mantenimiento

### Limpiar Logs
```bash
# Limpiar logs de Nginx
docker exec reverse-proxy sh -c ':> /var/log/nginx/copilot_access.log; :> /var/log/nginx/copilot_error.log; :> /var/log/nginx/copilot_noauth_access.log; :> /var/log/nginx/copilot_noauth_error.log; :> /var/log/nginx/copilot_oauth_access.log; :> /var/log/nginx/copilot_oauth_error.log'
```

### Reiniciar Servicios
```bash
# Reiniciar todos
docker compose restart

# Reiniciar servicio específico
docker compose restart copilot-metrics-viewer
docker compose restart copilot-metrics-viewer-hdi
```

### Actualizar Imagen
```bash
# Reconstruir y redesplegar
docker build -t copilot-metrics-hdi .
docker compose up -d --force-recreate
```

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Nginx Reverse Proxy                      │
│                     (Puerto 80)                            │
└─────────────────┬───────────────────┬───────────────────────┘
                  │                   │
                  │                   │
    ┌─────────────▼─────────────┐    ┌▼─────────────────────────┐
    │  /copilot-metrics-viewer/ │    │ /copilot-metrics-viewer- │
    │   (Sin OAuth)             │    │     hdi/ (Con OAuth)     │
    │                           │    │                         │
    │  copilot-metrics-viewer   │    │ copilot-metrics-viewer-  │
    │  (env.noauth)             │    │     hdi (env.oauth)      │
    └───────────────────────────┘    └─────────────────────────┘
```

## 🐛 Solución de Problemas

### Error 404 en Assets
- Verificar que `NUXT_APP_BASE_URL` esté configurado correctamente
- Reconstruir la imagen Docker

### Error de OAuth
- Verificar configuración de GitHub OAuth App
- Confirmar que el callback URL sea correcto
- Revisar logs del contenedor

### Error de DNS/Red
- Verificar conectividad desde el contenedor
- Revisar configuración de proxy corporativo
- Confirmar resolución DNS

## 📝 Notas Importantes

- Ambas versiones usan la misma imagen Docker
- La diferencia está en las variables de entorno
- Los logs están separados por versión
- El Nginx maneja el enrutamiento automáticamente
- Cada versión tiene su propio health check
