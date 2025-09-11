// Script para habilitar logging detallado en Node.js
process.on('uncaughtException', (error) => {
  console.error('🚨 UNCAUGHT EXCEPTION:', error);
  console.error('Stack trace:', error.stack);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('🚨 UNHANDLED REJECTION at:', promise, 'reason:', reason);
  console.error('Stack trace:', reason.stack);
});

// Habilitar logging detallado
process.env.DEBUG = '*';
process.env.NODE_ENV = 'development';

console.log('🔍 Debug logging enabled');
console.log('🔍 Node.js version:', process.version);
console.log('🔍 Environment variables:');
console.log('  - NUXT_PUBLIC_USING_GITHUB_AUTH:', process.env.NUXT_PUBLIC_USING_GITHUB_AUTH);
console.log('  - NODE_ENV:', process.env.NODE_ENV);
console.log('  - DEBUG:', process.env.DEBUG);
