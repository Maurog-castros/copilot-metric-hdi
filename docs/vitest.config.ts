import { defineVitestConfig } from '@nuxt/test-utils/config'

export default defineVitestConfig({
  // any custom Vitest config you require
  test: {
    exclude: ['**/node_modules/**', '**/testing/e2e-tests/**'],
    environment: 'nuxt',
    globals: true, // Use describe, test/expect, etc. without importing
    setupFiles: ['./testing/tests/test.setup.ts']
  }
})
