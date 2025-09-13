import { H3Event } from 'h3';
import crypto from 'crypto';

export default defineEventHandler(async (event: H3Event) => {
  // Lee el secret del webhook desde variables de entorno
  const secret = process.env.GITHUB_WEBHOOK_SECRET;
  if (!secret) {
    return { error: 'Webhook secret no configurado' };
  }

  // Lee el cuerpo del request
  const body = await readRawBody(event);
  const signature = event.node.req.headers['x-hub-signature-256'] as string;

  // Valida la firma del webhook
  const hmac = crypto.createHmac('sha256', secret);
  hmac.update(body || '');
  const digest = 'sha256=' + hmac.digest('hex');

  if (signature !== digest) {
    return { error: 'Firma inválida' };
  }

  // Procesa el evento recibido
  const payload = JSON.parse(body || '{}');
  // Aquí puedes agregar lógica para manejar diferentes tipos de eventos
  // Ejemplo: if (payload.action === 'opened') { ... }

  return { ok: true, event: event.node.req.headers['x-github-event'], payload };
});
