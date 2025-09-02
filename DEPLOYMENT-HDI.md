# 🚀 Despliegue de Copilot Metrics Viewer en HDI

Este documento describe cómo desplegar la aplicación **Copilot Metrics Viewer** en el servidor de HDI usando Docker.

## 📋 Prerrequisitos

- **Docker** instalado en el servidor
- **Docker Compose** (incluido con Docker Desktop o instalado por separado)
- **Token de GitHub** con permisos para acceder a la organización `hdicl`
- **Puerto 3000** disponible en el servidor

## 🏗️ Arquitectura de la Aplicación

La aplicación está construida con:
- **Frontend**: Nuxt.js 4 con Vue.js 3
- **Backend**: API REST con Nitro (Nuxt)
- **UI**: Vuetify 3 con tema corporativo de HDI
- **Autenticación**: OAuth de GitHub (opcional)
- **Base de datos**: Sesiones en memoria (configurable)

## 📁 Archivos de Despliegue

- `Dockerfile.hdi` - Imagen Docker optimizada para producción
- `docker-compose.hdi.yml` - Configuración de servicios Docker
- `env.hdi.example` - Plantilla de variables de entorno
- `deploy-hdi.sh` - Script automatizado de despliegue

## ⚙️ Configuración

### 1. Variables de Entorno

Copia el archivo de ejemplo y configura las variables:

```bash
cp env.hdi.example .env
```

Edita el archivo `.env` con tus credenciales:

```bash
# Token de GitHub (requerido)
GITHUB_TOKEN=ghp_your_actual_token_here

# Contraseña de sesión (mínimo 32 caracteres)
SESSION_PASSWORD=your_super_secret_password_that_is_at_least_32_characters_long

# Configuración OAuth (opcional)
GITHUB_CLIENT_ID=your_github_oauth_client_id
GITHUB_CLIENT_SECRET=your_github_oauth_client_secret
```

### 2. Configuración de GitHub

La aplicación está configurada para:
- **Organización**: `hdicl`
- **Scope**: `organization` (métricas de toda la organización)
- **Datos**: Reales (no mock)

## 🚀 Despliegue Automatizado

### Opción 1: Script de Despliegue (Recomendado)

```bash
# Dar permisos de ejecución
chmod +x deploy-hdi.sh

# Ejecutar despliegue
./deploy-hdi.sh
```

### Opción 2: Comandos Manuales

```bash
# Construir imagen
docker-compose -f docker-compose.hdi.yml build

# Iniciar servicios
docker-compose -f docker-compose.hdi.yml up -d

# Ver logs
docker-compose -f docker-compose.hdi.yml logs -f
```

## 🌐 Acceso a la Aplicación

Una vez desplegada, la aplicación estará disponible en:

- **URL Principal**: http://localhost:3000
- **Health Check**: http://localhost:3000/api/health
- **API Metrics**: http://localhost:3000/api/metrics

## 📊 Características de la Aplicación

### Tabs Disponibles:
1. **Lenguajes** - Análisis de lenguajes de programación
2. **Editores** - Uso de editores de código
3. **Chat Copilot** - Métricas de Copilot Chat
4. **GitHub.com** - Análisis de modelos de GitHub
5. **Análisis de Asientos** - Gestión de licencias Copilot
6. **Respuesta API** - Datos raw de la API

### Funcionalidades:
- ✅ Filtros de rango de fechas
- ✅ Exclusión de feriados/fines de semana
- ✅ Exportación a CSV
- ✅ Autenticación OAuth (opcional)
- ✅ Tema corporativo HDI
- ✅ Responsive design
- ✅ Health checks automáticos

## 🔧 Mantenimiento

### Comandos Útiles:

```bash
# Ver estado de los servicios
docker-compose -f docker-compose.hdi.yml ps

# Ver logs en tiempo real
docker-compose -f docker-compose.hdi.yml logs -f

# Reiniciar aplicación
docker-compose -f docker-compose.hdi.yml restart

# Detener servicios
docker-compose -f docker-compose.hdi.yml down

# Actualizar aplicación
git pull
docker-compose -f docker-compose.hdi.yml build
docker-compose -f docker-compose.hdi.yml up -d
```

### Logs y Monitoreo:

- **Logs de aplicación**: `./logs/`
- **Health check**: Cada 30 segundos
- **Métricas**: Disponibles en `/api/health`

## 🚨 Solución de Problemas

### Problemas Comunes:

1. **Puerto 3000 ocupado**:
   ```bash
   # Cambiar puerto en docker-compose.hdi.yml
   ports:
     - "3001:3000"  # Usar puerto 3001 externamente
   ```

2. **Token de GitHub inválido**:
   - Verificar permisos del token
   - Asegurar acceso a la organización `hdicl`

3. **Error de permisos**:
   ```bash
   # Dar permisos al directorio de logs
   sudo chown -R $USER:$USER logs/
   ```

### Verificar Estado:

```bash
# Health check manual
curl http://localhost:3000/api/health

# Ver logs de errores
docker-compose -f docker-compose.hdi.yml logs --tail=50 | grep ERROR
```

## 🔒 Seguridad

- **Usuario no-root**: La aplicación corre como usuario `nuxt`
- **Variables de entorno**: Credenciales sensibles en archivo `.env`
- **Health checks**: Monitoreo automático del estado
- **Logs**: Sin información sensible en logs

## 📞 Soporte

Para problemas técnicos o soporte:
- Revisar logs: `docker-compose -f docker-compose.hdi.yml logs`
- Verificar health check: http://localhost:3000/api/health
- Documentación: README.md principal del proyecto

---

**¡La aplicación está lista para usar en HDI! 🎉**
