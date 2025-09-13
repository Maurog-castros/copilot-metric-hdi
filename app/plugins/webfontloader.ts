/**
 * plugins/webfontloader.js
 *
 * webfontloader documentation: https://github.com/typekit/webfontloader
 */
export default defineNuxtPlugin(() => {
  // Cargar fuentes solo en el cliente
  if (import.meta.client) {
    // Usar nextTick para asegurar que el DOM esté listo
    nextTick(() => {
      loadFonts()
    })
  }
})


async function loadFonts () {
  try {
    const webFontLoader = await import(/* webpackChunkName: "webfontloader" */'webfontloader')

    webFontLoader.load({
      google: {
        families: ['Roboto:100,300,400,500,700,900&display=swap'],
      },
    })
  } catch (error) {
    console.warn('Error loading fonts:', error)
  }
}
