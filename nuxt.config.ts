// https://nuxt.com/docs/api/configuration/nuxt-config
// Read package.json version at build time
let version = '0.0.0';
try {
  const packageJson = await import('./package.json', { assert: { type: 'json' } });
  version = packageJson.default.version;
} catch (error) {
  console.warn('Could not read package.json version:', error);
}

export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: {
    enabled: true,

    timeline: {
      enabled: true
    }
  },

  future: {
    compatibilityVersion: 4
  },

  ssr: true,

  app: {
    head: {
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.svg' }
      ]
    }
  },

  // when enabling ssr option you need to disable inlineStyles and maybe devLogs
  features: {
    inlineStyles: false,
    devLogs: false,
  },

  build: {
    transpile: ['vuetify'],
  },

  vite: {
    ssr: {
      noExternal: ['vuetify'],
    },
  },

  css: [
    '@/assets/global.css'
  ],
  modules: ['@nuxt/fonts', 'vuetify-nuxt-module', '@nuxt/eslint', 'nuxt-auth-utils'],

  vuetify: {
    moduleOptions: {
      // check https://nuxt.vuetifyjs.com/guide/server-side-rendering.html
      ssrClientHints: {
        reloadOnFirstRequest: false,
        viewportSize: true,
        prefersColorScheme: false,

        prefersColorSchemeOptions: {
          useBrowserThemeOnly: false,
        },
      },

      // /* If customizing sass global variables ($utilities, $reset, $color-pack, $body-font-family, etc) */
      // disableVuetifyStyles: true,
      styles: {
        configFile: 'assets/settings.scss',
      },
      
      // Configuración adicional para mejorar la hidratación
      treeshaking: true,
      autoImport: true,
    },
    
    // Configuración global de Vuetify
    vuetifyOptions: {
      defaults: {
        VCard: {
          elevation: 3,
        },
        VCardTitle: {
          class: 'text-h6 pa-4 pb-2',
        },
        VCardText: {
          class: 'pa-4 pt-0',
        },
      },
    },
  },

  // Auth configuration moved to runtimeConfig
  nitro: {
    plugins: [
      'plugins/http-agent',
    ],
  },
  runtimeConfig: {
    githubToken: '',
    session: {
      // set to 6h - same as the GitHub token
      maxAge: 60 * 60 * 6,
      password: '',
    },
    oauth: {
      github: {
        clientId: '',
        clientSecret: ''
      }
    },
    public: {
      isDataMocked: false,  // can be overridden by NUXT_PUBLIC_IS_DATA_MOCKED environment variable
      scope: 'organization',  // can be overridden by NUXT_PUBLIC_SCOPE environment variable
      githubOrg: '',
      githubEnt: '',
      githubTeam: '',
      usingGithubAuth: false,
      version,
      isPublicApp: false
    }
  }
})