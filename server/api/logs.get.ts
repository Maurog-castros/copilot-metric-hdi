export default defineEventHandler(async (event) => {
  try {
    // Obtener logs del contenedor Docker
    const { execSync } = await import('child_process')
    
    const logs = execSync('docker logs --tail 50 copilot-metrics-hdi', { 
      encoding: 'utf8',
      timeout: 5000 
    })
    
    return {
      success: true,
      logs: logs.split('\n').filter(line => line.trim() !== ''),
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
