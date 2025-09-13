export default defineNuxtPlugin(() => {
  const currentOrg = ref('hdicl');
  const availableOrgs = ['hdicl']; // Solo hdicl tiene Copilot habilitado

  const changeOrganization = (org: string) => {
    if (availableOrgs.includes(org)) {
      currentOrg.value = org;
      // Emitir evento para que otros componentes se enteren
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new CustomEvent('organization-changed', { detail: org }));
      }
    }
  };

  return {
    provide: {
      organizations: {
        current: readonly(currentOrg),
        available: availableOrgs,
        change: changeOrganization
      }
    }
  };
});
