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
    description: 'Organización principal de HDI Chile con repositorios corporativos',
    repos: 25,
    members: 45,
    color: 'success',
    icon: 'mdi-office-building',
    githubOrg: 'hdicl',
    scope: 'organization'
  },
  'HDISeguros-cl': {
    value: 'HDISeguros-cl',
    title: 'HDI Seguros Chile (HDISeguros-cl)',
    description: 'Organización de seguros de HDI Chile con proyectos especializados',
    repos: 18,
    members: 32,
    color: 'primary',
    icon: 'mdi-shield-check',
    githubOrg: 'HDISeguros-cl',
    scope: 'organization'
  }
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
  return ORGANIZATIONS['hdicl'];
};
