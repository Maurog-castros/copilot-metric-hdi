declare module '#app' {
  interface RuntimeConfig {
    public: {
      scope?: string;
      githubOrg?: string;
      githubEnt?: string;
      githubTeam?: string;
      isDataMocked?: boolean;
      organizations?: string[];
    };
  }
}

declare module '@vue/runtime-core' {
  interface ComponentCustomProperties {
    $organizations: {
      current: string;
      available: string[];
      change: (org: string) => void;
    };
  }
}

export {};
