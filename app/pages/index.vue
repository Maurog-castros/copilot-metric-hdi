<script lang="ts" setup>
import './assets/global.css';

// TODO: there might be a better way than overriding the config with route
const config = useRuntimeConfig();
const route = useRoute();

// Use watchEffect to reactively update config when route changes
watchEffect(() => {
  if(route.query.mock) {
    config.public.isDataMocked = true;
    config.public.usingGithubAuth = false;
  }

  if (route.params.ent || route.params.org) {
    config.public.githubEnt = route.params.ent as string
    config.public.githubOrg = route.params.org as string
    config.public.githubTeam = route.params.team as string

    
    // update scope
    if (route.params.org && route.params.team) {
      config.public.scope = 'team-organization'
    } else if (route.params.org) {
      config.public.scope = 'organization'
    } else if (route.params.ent && route.params.team) {
      config.public.scope = 'team-enterprise'
    } else if (route.params.ent) {
      config.public.scope = 'enterprise'
    } 
  }
});

const version = computed(() => config.public.version);
</script>

<template>
  <MainComponent />
</template>
