import { ORGANIZATIONS, type Organization } from '@/config/organizations';

export const useOrganizations = () => {
  const currentOrg = useState<string>('current-organization', () => 'hdicl');
  
  const availableOrgs = computed(() => Object.keys(ORGANIZATIONS));
  
  const currentOrganization = computed(() => ORGANIZATIONS[currentOrg.value]);
  
  const changeOrganization = (org: string) => {
    if (ORGANIZATIONS[org]) {
      currentOrg.value = org;
      // Emitir evento para notificar cambios
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new CustomEvent('organization-changed', { detail: org }));
      }
    }
  };
  
  const getOrganization = (value: string): Organization | undefined => {
    return ORGANIZATIONS[value];
  };
  
  const getOrganizationsList = (): Organization[] => {
    return Object.values(ORGANIZATIONS);
  };
  
  return {
    currentOrg: readonly(currentOrg),
    currentOrganization,
    availableOrgs,
    changeOrganization,
    getOrganization,
    getOrganizationsList
  };
};
