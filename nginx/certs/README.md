# Certificados SSL para HDI Copilot Metrics Viewer

Este directorio contiene los certificados SSL para la configuración HTTPS de la aplicación.

## Archivos Requeridos

Para habilitar HTTPS, necesitas los siguientes archivos:

- `copilot-metrics.crt` - Certificado SSL público
- `copilot-metrics.key` - Clave privada del certificado

## Generación de Certificados

### Opción 1: Certificado Autofirmado (Desarrollo)

```bash
# Generar clave privada
openssl genrsa -out copilot-metrics.key 2048

# Generar certificado autofirmado
openssl req -new -x509 -key copilot-metrics.key -out copilot-metrics.crt -days 365 \
  -subj "/C=CL/ST=Santiago/L=Santiago/O=HDI Seguros/OU=IT/CN=copilot-metrics.hdi.cl"
```

### Opción 2: Certificado de CA Corporativa (Producción)

1. **Generar CSR (Certificate Signing Request):**
```bash
# Generar clave privada
openssl genrsa -out copilot-metrics.key 2048

# Generar CSR
openssl req -new -key copilot-metrics.key -out copilot-metrics.csr \
  -subj "/C=CL/ST=Santiago/L=Santiago/O=HDI Seguros/OU=IT/CN=copilot-metrics.hdi.cl"
```

2. **Enviar CSR a la CA corporativa de HDI**

3. **Recibir certificado firmado y colocarlo como `copilot-metrics.crt`**

## Configuración de Permisos

```bash
# Establecer permisos seguros
chmod 600 copilot-metrics.key
chmod 644 copilot-metrics.crt
```

## Verificación

```bash
# Verificar certificado
openssl x509 -in copilot-metrics.crt -text -noout

# Verificar clave privada
openssl rsa -in copilot-metrics.key -check
```

## Notas de Seguridad

- **NUNCA** commitees archivos `.key` al repositorio
- Los certificados deben renovarse antes de su expiración
- Usa certificados de CA corporativa para producción
- Mantén las claves privadas seguras y con permisos restrictivos

## Integración con Docker

Los certificados se montan en el contenedor de Nginx a través del volumen:

```yaml
volumes:
  - ./nginx/certs:/etc/nginx/certs:ro
```

Esto permite que Nginx acceda a los certificados sin exponerlos en la imagen Docker.
