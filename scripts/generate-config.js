#!/usr/bin/env node

// Script para generar archivo de configuración dinámico en el servidor
const fs = require('fs');
const path = require('path');

// Leer variables de entorno
const config = {
  githubToken: process.env.NUXT_GITHUB_TOKEN || '',
  githubOrg: process.env.NUXT_PUBLIC_GITHUB_ORG || '',
  githubEnt: process.env.NUXT_PUBLIC_GITHUB_ENT || '',
  githubTeam: process.env.NUXT_PUBLIC_GITHUB_TEAM || '',
  scope: process.env.NUXT_PUBLIC_SCOPE || 'organization',
  isDataMocked: process.env.NUXT_PUBLIC_IS_DATA_MOCKED === 'true',
  usingGithubAuth: process.env.NUXT_PUBLIC_USING_GITHUB_AUTH === 'true',
  sessionPasswordLast4: (process.env.NUXT_SESSION_PASSWORD || '').slice(-4),
  githubClientIdLast4: (process.env.NUXT_OAUTH_GITHUB_CLIENT_ID || '').slice(-4),
  githubClientSecretLast4: (process.env.NUXT_OAUTH_GITHUB_CLIENT_SECRET || '').slice(-4),
  version: process.env.npm_package_version || '0.0.0',
  timestamp: new Date().toISOString()
};

// Generar archivo de configuración
const configPath = path.join(__dirname, '../public/config.json');
fs.writeFileSync(configPath, JSON.stringify(config, null, 2));

console.log('✅ Configuración generada en:', configPath);
console.log('📋 Configuración:', JSON.stringify(config, null, 2));
