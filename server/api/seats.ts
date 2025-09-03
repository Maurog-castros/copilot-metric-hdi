// server/api/seats.ts
import { defineEventHandler, getQuery, getRequestHeader, createError } from 'h3';
import { ofetch as $fetch } from 'ofetch';
import { readFileSync } from 'fs';
import { resolve } from 'path';

// OJO: en tu repo los modelos están en app/model/*
import { Seat } from '../../app/model/Seat';
import { Options } from '../../app/model/Options';

// -------- utils --------
function isBad(value?: string) {
  if (!value) return true;
  if (value.toLowerCase() === 'teams') return true; // se cuela desde la pestaña Teams
  return !/^[A-Za-z0-9._-]+$/.test(value);
}

// Minimal shape para miembros de equipo
export interface TeamMember {
  login: string;
  id: number;
  [key: string]: unknown;
}

/** Pagina miembros de un team (org/team o ent/team) */
async function fetchAllTeamMembers(options: Options, headers: Record<string, string>): Promise<TeamMember[]> {
  if (!(options.scope === 'team-organization' || options.scope === 'team-enterprise') || !options.githubTeam) {
    return [];
  }

  const url = options.getTeamMembersApiUrl();
  const perPage = 100;
  let page = 1;
  const out: TeamMember[] = [];

  // loop simple sin parsear Link para funcionar igual con datos mockeados
  // @ts-ignore ofetch tipado genérico
  while (true) {
    const pageData = await $fetch<TeamMember[]>(url, { headers, params: { per_page: perPage, page } });
    if (!Array.isArray(pageData) || pageData.length === 0) break;
    out.push(...pageData);
    if (pageData.length < perPage) break;
    page++;
  }

  return out;
}

/** Dedup por id de usuario conservando la actividad más reciente */
function deduplicateSeats(seats: Seat[]): Seat[] {
  const map = new Map<number, Seat>();
  for (const s of seats) {
    if (!s.id || s.id === 0) continue;
    const prev = map.get(s.id);
    if (!prev) {
      map.set(s.id, s);
    } else {
      const a = s.last_activity_at || '1970-01-01T00:00:00Z';
      const b = prev.last_activity_at || '1970-01-01T00:00:00Z';
      if (a > b) map.set(s.id, s);
    }
  }
  return [...map.values()];
}

export default defineEventHandler(async (event) => {
  const logger = console;
  const query = getQuery(event);
  const options = Options.fromQuery(query);

  // Check if organization parameter is provided in query
  const githubOrg = query.githubOrg as string;
  if (githubOrg && !isBad(githubOrg)) {
    logger.info(`Using organization from query parameter: ${githubOrg}`);
    options.githubOrg = githubOrg;
  }

  // Normalizamos scope/org/ent si vienen mal desde el front
  const envScope = (process.env.METRICS_SCOPE || 'organization') as Options['scope'];
  options.scope = (options.scope || envScope) as any;

  if (options.scope === 'organization' || options.scope === 'team-organization') {
    if (isBad(options.githubOrg)) options.githubOrg = process.env.GH_ORG || process.env.NUXT_PUBLIC_GITHUB_ORG || '';
  } else if (options.scope === 'enterprise' || options.scope === 'team-enterprise') {
    if (isBad(options.githubEnt)) options.githubEnt = process.env.GH_ENTERPRISE || process.env.NUXT_PUBLIC_GITHUB_ENT || '';
  }

  // Rutas API (lanzan error si falta algo esencial)
  const apiUrl = options.getSeatsApiUrl();
  const mockedDataPath = options.getSeatsMockDataPath();

  // Headers para GitHub
  const bearer =
    getRequestHeader(event, 'authorization') ||
    (process.env.NUXT_GITHUB_TOKEN || process.env.GITHUB_TOKEN ? `Bearer ${process.env.NUXT_GITHUB_TOKEN || process.env.GITHUB_TOKEN}` : '');

  if (!bearer) {
    logger.error('No Authentication provided');
    return new Response('No Authentication provided', { status: 401 });
  }

  const ghHeaders: Record<string, string> = {
    Authorization: bearer,
    Accept: 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28'
  };

  // Mock
  if (options.isDataMocked && mockedDataPath) {
    const path = resolve(mockedDataPath);
    const data = readFileSync(path, 'utf8');
    const dataJson = JSON.parse(data);
    const seatsData = (dataJson.seats as unknown[]).map((x) => new Seat(x));
    const dedup = deduplicateSeats(seatsData);
    logger.info('Using mocked seats data');
    return dedup;
  }

  // (Opcional) filtrar por miembros de team si el scope es team-*
  const teamMembers = await fetchAllTeamMembers(options, ghHeaders);

  // --------- Paginación seats ----------
  const perPage = 100;
  let page = 1;

  logger.info(`Fetching 1st page of seats data from ${apiUrl}`);
  type SeatsResp = { seats: unknown[]; total_seats: number };

  let resp: SeatsResp;
  try {
    // @ts-ignore ofetch tipado genérico
    resp = await $fetch<SeatsResp>(apiUrl, { headers: ghHeaders, params: { per_page: perPage, page } });
  } catch (err: any) {
    logger.error('Error fetching seats data:', err);
    const status = err?.statusCode || err?.status || 500;
    throw createError({ statusCode: status, statusMessage: 'Error fetching seats data', data: String(err) });
  }

  let seats: Seat[] = resp.seats.map((x) => new Seat(x));
  const totalPages = Math.ceil((resp.total_seats || seats.length) / perPage);

  for (page = 2; page <= totalPages; page++) {
    // @ts-ignore
    const r = await $fetch<SeatsResp>(apiUrl, { headers: ghHeaders, params: { per_page: perPage, page } });
    seats = seats.concat(r.seats.map((x) => new Seat(x)));
  }

  const dedup = deduplicateSeats(seats);

  if (teamMembers.length > 0) {
    const ids = new Set(teamMembers.map((m) => m.id));
    return dedup.filter((s) => ids.has(s.id));
  }

  return dedup;
});
