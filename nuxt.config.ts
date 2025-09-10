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
    // baseURL y assets desde .env
    baseURL: process.env.NUXT_APP_BASE_URL || '/',
    buildAssetsDir: process.env.NUXT_APP_BUILD_ASSETS_DIR || '/_nuxt/',


    head: {
      link: [
        { 
		rel: 'icon', 
		type: 'image/x-icon', 
	        href: `${process.env.NUXT_APP_BASE_URL || ''}favicon.svg`

		
       	}
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

      styles: {
        configFile: 'assets/settings.scss',
      },

      // Configuración adicional para mejorar la hidratación
      treeshaking: true,
      autoImport: true,
    },

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

  nitro: {
    plugins: [
      'plugins/http-agent',
    ],
  },
  runtimeConfig: {
    githubToken: '',
    session: {
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
      isDataMocked: false,
      scope: 'organization',
      githubOrg: '',
      githubEnt: '',
      githubTeam: '',
      usingGithubAuth: false,
      version,
      isPublicApp: false
    }
  }
})

