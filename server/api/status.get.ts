export default defineEventHandler(async (event) => {
  try {
    // Obtener información del contenedor
    const { execSync } = await import('child_process')
    
    const containerInfo = execSync('docker ps --filter name=copilot-metrics-hdi --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"', { 
      encoding: 'utf8',
      timeout: 5000 
    })
    
    const memoryUsage = execSync('docker stats copilot-metrics-hdi --no-stream --format "table {{.MemUsage}}\t{{.CPUPerc}}"', { 
      encoding: 'utf8',
      timeout: 5000 
    })
    
    return {
      success: true,
      container: {
        info: containerInfo.trim(),
        memory: memoryUsage.trim()
      },
      server: {
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        pid: process.pid
      },
      timestamp: new Date().toISOString()
    }
  } catch (error) {
    return {
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    }
  }
})
