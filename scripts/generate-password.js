import bcrypt from 'bcryptjs';

/**
 * Script para generar contraseñas hasheadas para el sistema de autenticación
 * Uso: node scripts/generate-password.js [contraseña]
 */

const password = process.argv[2] || 'password';
const saltRounds = 10;

async function generateHash() {
  try {
    const hash = await bcrypt.hash(password, saltRounds);
    console.log('Contraseña:', password);
    console.log('Hash generado:', hash);
    console.log('\nPara usar en el código, copia el hash generado.');
  } catch (error) {
    console.error('Error generando hash:', error);
  }
}

generateHash();
