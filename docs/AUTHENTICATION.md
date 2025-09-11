# 🔐 Sistema de Autenticación - HDI Copilot Metrics

Este documento describe las opciones de autenticación disponibles para la aplicación HDI Copilot Metrics.

## 📋 Opciones Disponibles

### 1. **Autenticación Simple con Token (Recomendada para HDI)**
**Complejidad: Muy Baja**

Esta es la opción más simple y ya está implementada. Solo requiere configurar un token de GitHub.

```bash
# En tu archivo .env
GITHUB_TOKEN=ghp_your_github_token_here
SESSION_PASSWORD=your_super_secret_password_that_is_at_least_32_characters_long
```

**Ventajas:**
- ✅ Cero configuración adicional
- ✅ Funciona inmediatamente
- ✅ Ideal para uso interno de HDI
- ✅ Sin complejidad de usuarios

**Desventajas:**
- ❌ Sin control de usuarios individuales
- ❌ Acceso público si no hay restricciones de red

---

### 2. **Autenticación Básica con Usuario/Contraseña**
**Complejidad: Baja**

Sistema de login implementado con usuarios predefinidos.

#### Usuarios Predefinidos

| Usuario | Contraseña | Rol |
|---------|------------|-----|
| `admin` | `password` | Administrador |
| `mauro.castro` | `password` | Usuario |
| `hdi.user` | `password` | Usuario |

#### Configuración

```bash
# En tu archivo .env
NUXT_PUBLIC_ENABLE_BASIC_AUTH=true
SESSION_PASSWORD=your_super_secret_password_that_is_at_least_32_characters_long
```

#### Generar Nuevas Contraseñas

Para generar contraseñas hasheadas seguras:

```bash
# Generar hash para contraseña "mi_contraseña_segura"
node scripts/generate-password.js mi_contraseña_segura
```

#### Personalizar Usuarios

Puedes definir usuarios personalizados en el archivo `server/api/auth/login.post.ts`:

```typescript
const AUTHORIZED_USERS = [
  {
    username: 'tu_usuario',
    password: '$2a$10$hash_generado_aqui',
    name: 'Tu Nombre',
    role: 'admin'
  }
]
```

**Ventajas:**
- ✅ Control de acceso por usuario
- ✅ Fácil de implementar
- ✅ Ideal para equipos pequeños
- ✅ Sin dependencias externas

**Desventajas:**
- ❌ Contraseñas hardcodeadas
- ❌ No escalable para muchos usuarios
- ❌ Sin recuperación de contraseña

---

### 3. **Autenticación OAuth con GitHub (Ya Implementada)**
**Complejidad: Media**

Sistema OAuth completo con GitHub (ya implementado en el proyecto).

```bash
# En tu archivo .env
NUXT_PUBLIC_USING_GITHUB_AUTH=true
NUXT_OAUTH_GITHUB_CLIENT_ID=your_github_oauth_client_id
NUXT_OAUTH_GITHUB_CLIENT_SECRET=your_github_oauth_client_secret
```

**Ventajas:**
- ✅ Integración con GitHub
- ✅ Gestión de permisos granular
- ✅ Escalable
- ✅ Estándar de la industria

**Desventajas:**
- ❌ Requiere configuración de GitHub App
- ❌ Más complejo de configurar
- ❌ Dependiente de GitHub

---

## 🚀 Implementación Recomendada para HDI

Para el entorno de HDI, recomiendo la **Opción 1 (Token Simple)** por las siguientes razones:

1. **Simplicidad**: Cero configuración adicional
2. **Seguridad**: Controlado por restricciones de red de HDI
3. **Mantenimiento**: Sin gestión de usuarios
4. **Rendimiento**: Sin overhead de autenticación

### Configuración Recomendada

```bash
# .env para HDI
GITHUB_TOKEN=ghp_your_github_token_here
SESSION_PASSWORD=your_super_secret_password_that_is_at_least_32_characters_long
NUXT_PUBLIC_ENABLE_BASIC_AUTH=false
NUXT_PUBLIC_USING_GITHUB_AUTH=false
```

### Seguridad Adicional

Para mayor seguridad, puedes:

1. **Restricciones de IP**: Configurar el servidor para solo permitir acceso desde la red de HDI
2. **HTTPS**: Usar certificados SSL
3. **Firewall**: Bloquear acceso externo
4. **VPN**: Requerir conexión VPN para acceder

---

## 🔧 Comandos Útiles

```bash
# Generar contraseña hasheada
node scripts/generate-password.js mi_contraseña

# Verificar instalación de dependencias
npm list bcryptjs

# Ejecutar en modo desarrollo
npm run dev

# Construir para producción
npm run build
```

---

## 📞 Soporte

Para dudas o problemas con la autenticación, contactar al equipo de DevOps de HDI.
