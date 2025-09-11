export default defineEventHandler(async (event) => {
  try {
    // Limpiar la sesión del usuario
    await clearUserSession(event)
    
    return {
      success: true,
      message: 'Logout exitoso'
    }
  } catch (error) {
    console.error('Logout error:', error)
    
    throw createError({
      statusCode: 500,
      statusMessage: 'Error al cerrar sesión'
    })
  }
})
