# Despliegue Manual de Archivos Estáticos - Copilot Metrics Viewer

## 📋 Pasos para desplegar manualmente

### 1. Preparar archivos en tu máquina local

```powershell
# Verificar que tienes la build
dir .output\public\

# Crear archivo comprimido
Compress-Archive -Path ".output\public\*" -DestinationPath "copilot-build.zip" -Force
```

### 2. Subir archivos al servidor

**Opción A: Usar WinSCP o similar**
- Conectarse a `192.168.1.24` con usuario `mcastro` y contraseña `HDI.2025`
- Subir `copilot-build.zip` a `/tmp/`

**Opción B: Usar PowerShell (si SSH funciona)**
```powershell
scp copilot-build.zip mcastro@192.168.1.24:/tmp/
```

### 3. Conectarse al servidor y extraer archivos

```bash
# Conectarse al servidor
ssh mcastro@192.168.1.24

# Extraer archivos
cd /home/Apps/statics/copilot-metrics/public
sudo rm -rf *
cd /tmp
sudo unzip -o copilot-build.zip -d /home/Apps/statics/copilot-metrics/public/
sudo chown -R mcastro:mcastro /home/Apps/statics/copilot-metrics/
sudo chmod -R 755 /home/Apps/statics/copilot-metrics/
rm copilot-build.zip
```

### 4. Levantar nginx reverse proxy

```bash
# Ir al directorio de nginx
cd /home/Apps/nginxReverseProxy

# Verificar configuración
cat nginx/conf.d/copilot-metrics.conf

# Levantar el servicio
docker-compose down
docker-compose up -d
```

### 5. Verificar que todo funciona

```bash
# Verificar contenedores
docker ps | grep nginx

# Verificar archivos
ls -la /home/Apps/statics/copilot-metrics/public/

# Verificar logs
docker logs reverse-proxy
```

### 6. Probar la aplicación

- Abrir navegador en: `http://192.168.1.24`
- Health check: `http://192.168.1.24/health`

## 🔧 Estructura final en el servidor

```
/home/Apps/
├── statics/
│   └── copilot-metrics/
│       └── public/                    # ← Archivos de .output/public
│           ├── index.html
│           ├── _nuxt/
│           ├── admin/
│           └── ...
└── nginxReverseProxy/
    ├── docker-compose.yml
    └── nginx/
        └── conf.d/
            └── copilot-metrics.conf   # ← Configuración creada
```

## 🚨 Solución de problemas

### Si nginx no inicia:
```bash
# Verificar configuración
docker exec reverse-proxy nginx -t

# Ver logs
docker logs reverse-proxy

# Reiniciar
docker-compose restart
```

### Si no se ven los archivos:
```bash
# Verificar permisos
ls -la /home/Apps/statics/copilot-metrics/public/

# Corregir permisos
sudo chown -R mcastro:mcastro /home/Apps/statics/copilot-metrics/
sudo chmod -R 755 /home/Apps/statics/copilot-metrics/
```

### Si hay problemas de red:
```bash
# Verificar red Docker
docker network ls

# Verificar que el contenedor está en la red correcta
docker inspect reverse-proxy | grep NetworkMode
```

## 📝 Comandos útiles

```bash
# Ver estado de contenedores
docker ps -a

# Ver logs en tiempo real
docker logs -f reverse-proxy

# Reiniciar nginx
docker-compose restart

# Parar todo
docker-compose down

# Ver configuración de nginx
docker exec reverse-proxy cat /etc/nginx/conf.d/copilot-metrics.conf
```
