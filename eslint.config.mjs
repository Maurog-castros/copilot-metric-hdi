// @ts-check
import withNuxt from './.nuxt/eslint.config.mjs'

export default withNuxt(
  // Your custom configs here
  {
    ignores: [
      'example-nextjs-github-oauth/**/*',
      '**/.next/**/*',
      '**/node_modules/**/*'
    ]
  }
)
