import bcrypt from 'bcryptjs'

// Usuarios autorizados (en producción, esto debería estar en una base de datos)
const AUTHORIZED_USERS = [
  {
    username: 'admin',
    password: '$2b$10$cisJITJxW5D7.lBZrdxbs.wutz5Qd7BJfYdgBFoiEsdOhmNW/NqXa', // password: "hdi123"
    name: 'Administrador HDI',
    role: 'admin'
  },
  {
    username: 'mauro.castro',
    password: '$2b$10$cisJITJxW5D7.lBZrdxbs.wutz5Qd7BJfYdgBFoiEsdOhmNW/NqXa', // password: "hdi123"
    name: 'Mauro Castro',
    role: 'user'
  },
  {
    username: 'hdi.user',
    password: '$2b$10$cisJITJxW5D7.lBZrdxbs.wutz5Qd7BJfYdgBFoiEsdOhmNW/NqXa', // password: "hdi123"
    name: 'Usuario HDI',
    role: 'user'
  }
]

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event)
    const { username, password } = body

    // Validar que se proporcionaron las credenciales
    if (!username || !password) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Usuario y contraseña son requeridos'
      })
    }

    // Buscar el usuario
    const user = AUTHORIZED_USERS.find(u => u.username === username)
    
    if (!user) {
      throw createError({
        statusCode: 401,
        statusMessage: 'Credenciales inválidas'
      })
    }

    // Verificar la contraseña
    const isValidPassword = await bcrypt.compare(password, user.password)
    
    if (!isValidPassword) {
      throw createError({
        statusCode: 401,
        statusMessage: 'Credenciales inválidas'
      })
    }

    // Crear sesión de usuario
    await setUserSession(event, {
      user: {
        username: user.username,
        name: user.name,
        role: user.role,
        isAuthenticated: true,
        loginTime: new Date().toISOString()
      }
    })

    return {
      success: true,
      message: 'Login exitoso',
      user: {
        username: user.username,
        name: user.name,
        role: user.role
      }
    }

  } catch (error: any) {
    console.error('Login error:', error)
    
    if (error.statusCode) {
      throw error
    }
    
    throw createError({
      statusCode: 500,
      statusMessage: 'Error interno del servidor'
    })
  }
})
