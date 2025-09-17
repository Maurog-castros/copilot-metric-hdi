# Validación de Variables de Entorno

Este documento describe el sistema de validación de variables de entorno implementado en el proyecto Copilot Metrics Viewer HDI.

## Archivos Implementados

### 1. Archivo de Configuración de Ejemplo
- **Archivo**: `.env.example`
- **Propósito**: Plantilla con todas las variables de entorno necesarias
- **Uso**: Copiar a `.env` y configurar los valores

### 2. Endpoints de API de Validación

#### `/api/config`
- **Propósito**: Servir configuración dinámica del servidor
- **Método**: GET
- **Respuesta**: Objeto con configuración actual

#### `/api/validate/server-config`
- **Propósito**: Validar configuración básica del servidor
- **Método**: GET
- **Respuesta**: Estado de validación de variables básicas

#### `/api/validate/github-token`
- **Propósito**: Validar token de GitHub con la API
- **Método**: GET
- **Respuesta**: Estado del token y información del usuario

#### `/api/validate/org-access`
- **Propósito**: Validar acceso a la organización y datos de Copilot
- **Método**: GET
- **Respuesta**: Estado de acceso y información de la organización

### 3. Composables

#### `useDynamicConfig()`
- **Archivo**: `app/composables/useDynamicConfig.ts`
- **Propósito**: Cargar configuración dinámica del servidor
- **Uso**: Para obtener configuración actualizada en tiempo real

#### `useConfigValidation()`
- **Archivo**: `app/composables/useConfigValidation.ts`
- **Propósito**: Validar toda la configuración del sistema
- **Uso**: Para verificar que todo esté configurado correctamente

### 4. Componente de Validación

#### `ConfigValidationModal`
- **Archivo**: `app/components/ConfigValidationModal.vue`
- **Propósito**: Modal para mostrar el estado de validación
- **Uso**: Para diagnosticar problemas de configuración

## Variables de Entorno Requeridas

### Configuración Básica de GitHub
- `NUXT_GITHUB_TOKEN`: Token de GitHub (mínimo 10 caracteres)
- `NUXT_PUBLIC_GITHUB_ORG`: Nombre de la organización
- `NUXT_PUBLIC_SCOPE`: Alcance de la aplicación (organization/enterprise/team)

### Configuración de Autenticación
- `NUXT_SESSION_PASSWORD`: Password de sesión (mínimo 32 caracteres)
- `NUXT_PUBLIC_USING_GITHUB_AUTH`: Habilitar autenticación OAuth
- `NUXT_OAUTH_GITHUB_CLIENT_ID`: Client ID de OAuth
- `NUXT_OAUTH_GITHUB_CLIENT_SECRET`: Client Secret de OAuth

### Configuración Opcional
- `NUXT_PUBLIC_IS_DATA_MOCKED`: Usar datos simulados
- `NUXT_PUBLIC_GITHUB_ENT`: Organización enterprise
- `NUXT_PUBLIC_GITHUB_TEAM`: Equipo específico

## Uso del Sistema de Validación

### 1. Configurar Variables de Entorno
```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar variables necesarias
nano .env
```

### 2. Usar el Composable de Validación
```typescript
// En un componente Vue
const { validateAll, loading, error } = useConfigValidation()

// Validar toda la configuración
const result = await validateAll()
console.log('Configuración válida:', result.allValid)
```

### 3. Mostrar Modal de Validación
```vue
<template>
  <ConfigValidationModal ref="validationModal" />
  <v-btn @click="showValidation">Validar Configuración</v-btn>
</template>

<script setup>
const validationModal = ref()

const showValidation = () => {
  validationModal.value.openModal()
}
</script>
```

## Validaciones Implementadas

### 1. Configuración del Servidor
- ✅ Token de GitHub presente y con longitud mínima
- ✅ Organización GitHub configurada
- ✅ Password de sesión con longitud mínima

### 2. Token de GitHub
- ✅ Token válido y no expirado
- ✅ Permisos suficientes para la API
- ✅ Información del usuario accesible

### 3. Acceso a la Organización
- ✅ Acceso a la organización configurada
- ✅ Permisos para datos de Copilot
- ✅ Información de asientos de Copilot disponible

## Mensajes de Error

El sistema proporciona mensajes de error específicos para cada tipo de problema:

- **Token inválido**: Token expirado o sin permisos
- **Organización no encontrada**: Nombre de organización incorrecto
- **Sin permisos de Copilot**: Falta acceso a datos de Copilot
- **Rate limit**: Límite de API excedido

## Desarrollo y Debugging

Para diagnosticar problemas de configuración:

1. Usar el modal de validación para ver el estado actual
2. Revisar los logs del servidor para errores detallados
3. Verificar que todas las variables estén configuradas correctamente
4. Probar el token de GitHub manualmente en la API

## Seguridad

- Los tokens y passwords sensibles no se exponen en el frontend
- Solo se muestran los últimos 4 caracteres para verificación
- Las validaciones se realizan en el servidor
- Los errores detallados solo se muestran en desarrollo

## Ejemplo de Archivo .env

```bash
# Configuración básica
NUXT_GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
NUXT_PUBLIC_GITHUB_ORG=hdicl
NUXT_PUBLIC_SCOPE=organization
NUXT_PUBLIC_IS_DATA_MOCKED=false

# Autenticación
NUXT_SESSION_PASSWORD=HDI-Copilot-Metrics-2025-Super-Secret-Password-32-Chars-Minimum
NUXT_PUBLIC_USING_GITHUB_AUTH=true
NUXT_OAUTH_GITHUB_CLIENT_ID=your_client_id
NUXT_OAUTH_GITHUB_CLIENT_SECRET=your_client_secret

# Monitoreo (opcional)
GRAFANA_PASSWORD=admin
REDIS_PASSWORD=defaultpassword
LOG_LEVEL=info
LOG_FORMAT=json
```
