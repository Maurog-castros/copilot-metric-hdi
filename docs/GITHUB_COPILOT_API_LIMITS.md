# GitHub Copilot API Limits - Límites de la API

## 📅 Límites de Fecha para GitHub Copilot Metrics API

### **Restricciones Principales**

#### **1. Rango Máximo de Fechas**
- **Límite**: 100 días máximo
- **Razón**: GitHub limita la cantidad de datos históricos que se pueden consultar en una sola petición
- **Recomendación**: Usar rangos de 28 días para mejor rendimiento

#### **2. Fechas Futuras**
- **Límite**: No se permiten fechas futuras
- **Razón**: La API solo proporciona datos históricos
- **Buffer**: Se permite hasta 1 día en el futuro para compensar zonas horarias

#### **3. Límite Histórico**
- **Límite**: Máximo 365 días hacia atrás
- **Razón**: GitHub Copilot se lanzó en 2022, los datos anteriores no están disponibles
- **Advertencia**: Datos muy antiguos pueden estar incompletos o no disponibles

### **Validaciones Implementadas**

#### **Validación Estricta (Por Defecto)**
```typescript
const validation = validateGitHubCopilotDateRange(since, until, {
  strictMode: true,        // Rechaza fechas inválidas
  allowFutureDates: false  // No permite fechas futuras
})
```

#### **Validación con Sugerencias**
```typescript
const validation = validateGitHubCopilotDateRange(since, until, {
  strictMode: false,       // Permite ajustes automáticos
  allowFutureDates: false
})
```

### **Mensajes de Error Comunes**

#### **❌ Errores de Validación**
- `El rango máximo permitido es de 100 días. Rango seleccionado: X días`
- `No se pueden consultar fechas futuras`
- `La fecha de inicio debe ser anterior a la fecha de fin`
- `La fecha de inicio no puede ser anterior a YYYY-MM-DD (365 días atrás)`

#### **⚠️ Advertencias**
- `La fecha de inicio está muy atrás en el tiempo. GitHub puede no tener datos disponibles`
- `La fecha de inicio es muy antigua. Los datos pueden no estar disponibles antes de 2022`
- `Rango ajustado automáticamente a 100 días para cumplir con los límites de la API`

### **Rangos Recomendados**

#### **🎯 Rango Óptimo (28 días)**
```typescript
const defaultRange = getDefaultDateRange()
// Últimos 28 días - Mejor rendimiento y datos completos
```

#### **📊 Rango Extendido (60 días)**
- Aceptable para análisis de tendencias
- Puede tener latencia aumentada
- Datos generalmente completos

#### **🚀 Rango Máximo (100 días)**
- Último recurso para análisis históricos
- Latencia significativa
- Posibles datos incompletos en fechas muy antiguas

### **Implementación en el Frontend**

#### **DateRangeSelector Component**
- **Validación en tiempo real** de las fechas seleccionadas
- **Indicadores visuales** del estado de validación
- **Botones de acción rápida** para rangos predefinidos
- **Mensajes informativos** sobre límites de la API

#### **Características del Selector**
- **Campo "Desde"**: Limitado a 365 días atrás
- **Campo "Hasta"**: Limitado a la fecha actual
- **Validación cruzada**: La fecha "desde" debe ser anterior a "hasta"
- **Feedback visual**: Colores y mensajes según el estado de validación

### **Manejo de Errores en el Backend**

#### **API Endpoints**
- **Validación previa** antes de hacer peticiones a GitHub
- **Mensajes de error claros** para el usuario
- **Logging detallado** para debugging

#### **Cache y Rendimiento**
- **Cache de 5 minutos** para evitar peticiones repetidas
- **Validación de autenticación** antes del cache
- **Manejo de rate limits** de GitHub

### **Casos de Uso Comunes**

#### **1. Análisis Diario**
- **Rango**: 1 día
- **Uso**: Métricas del día actual
- **Rendimiento**: Excelente

#### **2. Análisis Semanal**
- **Rango**: 7 días
- **Uso**: Comparación semanal de métricas
- **Rendimiento**: Muy bueno

#### **3. Análisis Mensual**
- **Rango**: 28-31 días
- **Uso**: Reportes mensuales
- **Rendimiento**: Bueno

#### **4. Análisis Trimestral**
- **Rango**: 90-100 días
- **Uso**: Análisis de tendencias trimestrales
- **Rendimiento**: Aceptable

### **Mejores Prácticas**

#### **✅ Recomendado**
- Usar rangos de 28 días para análisis regulares
- Validar fechas antes de hacer peticiones
- Implementar cache para rangos frecuentes
- Mostrar feedback claro al usuario sobre límites

#### **❌ Evitar**
- Rangos superiores a 100 días
- Fechas futuras
- Fechas muy antiguas (antes de 2022)
- Múltiples peticiones simultáneas con rangos grandes

### **Monitoreo y Alertas**

#### **Métricas a Monitorear**
- **Tiempo de respuesta** de la API de GitHub
- **Tasa de errores** por límites de fecha
- **Uso del cache** para optimizar rendimiento
- **Alertas** cuando se excedan los límites

#### **Logs Recomendados**
```typescript
logger.info(`Date range validation: ${since} to ${until} (${days} days)`)
logger.warn(`Date range near limit: ${days} days`)
logger.error(`Date range exceeds limit: ${days} days`)
```

### **Referencias**

- [GitHub Copilot Metrics API Documentation](https://docs.github.com/en/enterprise-cloud@latest/rest/copilot/copilot-usage)
- [GitHub API Rate Limits](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting)
- [GitHub Copilot Launch Date](https://github.blog/2022-06-21-github-copilot-is-generally-available-to-all-developers/)
