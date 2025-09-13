export interface Organization {
  value: string;
  title: string;
  description: string;
  repos: number;
  members: number;
  color: string;
  icon: string;
  githubOrg: string;
  scope: 'organization' | 'enterprise';
}

export const ORGANIZATIONS: Record<string, Organization> = {
  'hdicl': {
    value: 'hdicl',
    title: 'HDI Chile (hdicl)',
    description: 'Organización principal de HDI Chile con repositorios corporativos y Copilot habilitado',
    repos: 25,
    members: 45,
    color: 'success',
    icon: 'mdi-office-building',
    githubOrg: 'hdicl',
    scope: 'organization'
  }
  // HDISeguros-cl removido porque no tiene Copilot habilitado
};

export const getOrganization = (value: string): Organization | undefined => {
  return ORGANIZATIONS[value];
};

export const getOrganizationsList = (): Organization[] => {
  return Object.values(ORGANIZATIONS);
};

export const getOrganizationByGitHubOrg = (githubOrg: string): Organization | undefined => {
  return Object.values(ORGANIZATIONS).find(org => org.githubOrg === githubOrg);
};

export const getDefaultOrganization = (): Organization => {
  const org = ORGANIZATIONS['hdicl'];
  if (!org) {
    throw new Error('Default organization "hdicl" not found');
  }
  return org;
};
