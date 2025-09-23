// Tipos para validación de configuración

export interface ServerConfigValidation {
  valid: boolean
  githubToken: boolean
  githubOrg: boolean
  sessionPassword: boolean
  githubOrgName: string
  tokenLength: number
  sessionPasswordLast4: string
}

export interface GitHubUser {
  login: string
  name?: string
  email?: string
  id: number
}

export interface GitHubTokenValidation {
  valid: boolean
  user?: GitHubUser
  message?: string
  error?: string
}

export interface OrgAccessValidation {
  valid: boolean
  orgName?: string
  orgDisplayName?: string
  copilotSeats?: number
  message?: string
  error?: string
}

export interface DynamicConfig {
  githubToken: string
  githubOrg: string
  githubEnt: string
  githubTeam: string
  scope: string
  isDataMocked: boolean
  usingGithubAuth: boolean
  sessionPasswordLast4: string
  githubClientIdLast4: string
  githubClientSecretLast4: string
  version: string
}

export interface ValidationError {
  message: string
  statusCode?: number
  data?: any
}
