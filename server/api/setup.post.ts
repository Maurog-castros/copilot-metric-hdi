/**
 * Endpoint para registrar instalación del GitHub App
 * Guarda installation_id y setup_action en logs (o DB si tienes)
 */
export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { installation_id, setup_action } = body || {}

  if (!installation_id) {
    return {
      ok: false,
      error: 'installation_id requerido'
    }
  }

  // Aquí podrías guardar en una base de datos real
  // Por ahora solo loguea
  console.log('[GitHub App Setup] Nueva instalación:', {
    installation_id,
    setup_action,
    fecha: new Date().toISOString()
  })

  // (Opcional) Aquí podrías consultar la API de GitHub para obtener info de la instalación
  // Ejemplo: https://docs.github.com/en/rest/apps/installations?apiVersion=2022-11-28#get-an-installation-for-an-app

  return {
    ok: true,
    installation_id,
    setup_action
  }
})
