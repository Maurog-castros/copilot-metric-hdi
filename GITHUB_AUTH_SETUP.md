# Configuración de Autenticación GitHub para HDI

## URLs Configuradas

### URL Base de la Aplicación
- **URL Principal**: `http://vskpip01.hdi.chile/copilot-metrics-hdi/`
- **Callback URL**: `http://vskpip01.hdi.chile/copilot-metrics-hdi/auth/github`

## Configuración en GitHub.com

### 1. Crear GitHub App o OAuth App

#### Opción A: GitHub OAuth App (Recomendado)
1. Ve a GitHub.com → Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Configura:
   - **Application name**: `HDI Copilot Metrics`
   - **Homepage URL**: `http://vskpip01.hdi.chile/copilot-metrics-hdi/`
   - **Authorization callback URL**: `http://vskpip01.hdi.chile/copilot-metrics-hdi/auth/github`

#### Opción B: GitHub App
1. Ve a GitHub.com → Settings → Developer settings → GitHub Apps
2. Click "New GitHub App"
3. Configura:
   - **GitHub App name**: `HDI Copilot Metrics`
   - **Homepage URL**: `http://vskpip01.hdi.chile/copilot-metrics-hdi/`
   - **Webhook URL**: `http://vskpip01.hdi.chile/copilot-metrics-hdi/webhook`
   - **Callback URL**: `http://vskpip01.hdi.chile/copilot-metrics-hdi/auth/github`

### 2. Permisos Requeridos

#### Para OAuth App:
- `read:org` - Leer información de organizaciones
- `read:user` - Leer información del usuario
- `read:enterprise` - Leer información de enterprise (si aplica)

#### Para GitHub App:
- **Organization permissions**:
  - `Copilot usage` - Read
- **Repository permissions**:
  - `Contents` - Read (si es necesario)

### 3. Variables de Entorno

Crear archivo `.env` con:

```bash
# GitHub OAuth Configuration
NUXT_OAUTH_GITHUB_CLIENT_ID=your_github_client_id
NUXT_OAUTH_GITHUB_CLIENT_SECRET=your_github_client_secret
NUXT_OAUTH_GITHUB_CLIENT_SCOPE=read:org,read:user

# GitHub API Configuration
NUXT_GITHUB_TOKEN=your_github_personal_access_token

# Session Configuration
NUXT_SESSION_PASSWORD=your_session_password_32_chars_min

# Public Configuration
NUXT_PUBLIC_IS_DATA_MOCKED=false
NUXT_PUBLIC_SCOPE=organization
NUXT_PUBLIC_GITHUB_ORG=hdicl
NUXT_PUBLIC_GITHUB_ENT=
NUXT_PUBLIC_GITHUB_TEAM=
NUXT_PUBLIC_USING_GITHUB_AUTH=true
NUXT_PUBLIC_IS_PUBLIC_APP=false
```

## Rutas Configuradas

- **Home**: `/copilot-metrics-hdi/`
- **Auth Callback**: `/copilot-metrics-hdi/auth/github`
- **Organización**: `/copilot-metrics-hdi/orgs/{org}`
- **Equipo**: `/copilot-metrics-hdi/orgs/{org}/teams/{team}`
- **Enterprise**: `/copilot-metrics-hdi/enterprises/{ent}`

## Próximos Pasos

1. ✅ Configurar URL base en `nuxt.config.ts`
2. ✅ Actualizar URLs de callback en `server/routes/auth/github.get.ts`
3. 🔄 Crear GitHub App/OAuth App en GitHub.com
4. 🔄 Configurar variables de entorno
5. 🔄 Probar autenticación
