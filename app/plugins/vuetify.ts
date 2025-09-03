export default defineNuxtPlugin((nuxtApp) => {
  // check https://vuetify-nuxt-module.netlify.app/guide/nuxt-runtime-hooks.html
  nuxtApp.hook('vuetify:before-create', (options) => {
    if (import.meta.client) {
      // console.log('vuetify:before-create', options)
    }
    
    // Configuración para mejorar la hidratación
    if (options.defaults) {
      options.defaults.VCard = {
        elevation: 3,
        class: 'date-range-card'
      }
      
      options.defaults.VCardTitle = {
        class: 'text-h6 pa-4 pb-2'
      }
      
      options.defaults.VCardText = {
        class: 'pa-4 pt-0'
      }
    }
  })
  
  // Hook para después de la hidratación
  nuxtApp.hook('app:mounted', () => {
    // Forzar re-renderizado después de la hidratación
    if (import.meta.client) {
      nextTick(() => {
        // El componente ya está hidratado
      })
    }
  })
})
