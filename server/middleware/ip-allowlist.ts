import { defineEventHandler, getRequestHeader, createError } from 'h3';

function norm(ip?: string | null): string | null {
  if (!ip) return null;
  // quitar espacios y comillas accidentales
  let v = ip.trim().replace(/^"|"$/g, '');
  // IPv6-mapped IPv4 (::ffff:127.0.0.1)
  if (v.startsWith('::ffff:')) v = v.slice(7);
  // si viene con puerto (IPv4:port)
  if (v.includes(':') && /^\d{1,3}(\.\d{1,3}){3}:\d+$/.test(v)) {
    v = v.split(':')[0];
  }
  return v;
}

function isLocal(ip: string | null): boolean {
  if (!ip) return true; // en dev dejamos pasar IP desconocida
  return (
    ip === '127.0.0.1' ||
    ip === '::1' ||
    ip === '::ffff:127.0.0.1' ||
    ip.startsWith('10.') ||            // redes privadas comunes
    ip.startsWith('192.168.') ||
    ip.startsWith('172.16.') ||
    ip.startsWith('172.17.') ||
    ip.startsWith('172.18.') ||
    ip.startsWith('172.19.') ||
    ip.startsWith('172.20.') ||
    ip.startsWith('172.21.') ||
    ip.startsWith('172.22.') ||
    ip.startsWith('172.23.') ||
    ip.startsWith('172.24.') ||
    ip.startsWith('172.25.') ||
    ip.startsWith('172.26.') ||
    ip.startsWith('172.27.') ||
    ip.startsWith('172.28.') ||
    ip.startsWith('172.29.') ||
    ip.startsWith('172.30.') ||
    ip.startsWith('172.31.')
  );
}

export default defineEventHandler((event) => {
  // 1) Saltar chequeo en desarrollo
  if (process.env.NODE_ENV !== 'production') return;

  const url = event.path || event.node.req.url || '';

  // 2) No bloquear rutas internas de Nuxt/Vite/Devtools
  if (
    url.startsWith('/_nuxt/') ||
    url.startsWith('/__nuxt_devtools__') ||
    url === '/_vfs.json' ||
    url.startsWith('/__vite') ||
    url.startsWith('/@vite') ||
    url.startsWith('/@id/')
  ) {
    return;
  }

  // 3) Resolver IP del cliente
  const xff = getRequestHeader(event, 'x-forwarded-for'); // puede traer lista: "client, proxy1, proxy2"
  const firstHop = norm(xff?.split(',')[0] || null);
  const direct = norm(
    // @ts-ignore
    event.node.req.socket?.remoteAddress || event.node.req.connection?.remoteAddress || null
  );
  const ip = firstHop || direct || null;

  // 4) Allowlist desde .env
  const envList = (process.env.NUXT_IP_ALLOWLIST || '')
    .split(',')
    .map(s => norm(s) || '')
    .filter(Boolean);

  const inAllowlist = envList.length > 0 ? envList.includes(ip || '') : false;

  // 5) Reglas
  if (isLocal(ip) || inAllowlist) {
    return;
  }

  // 6) Bloqueo
  throw createError({
    statusCode: 403,
    message: `Forbidden IP: "${ip ?? '?'}"`
  });
});
