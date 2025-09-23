// import type { FetchError } from 'ofetch';

export default defineOAuthGitHubEventHandler({
  config: {
    scope: process.env.NUXT_OAUTH_GITHUB_CLIENT_SCOPE ? process.env.NUXT_OAUTH_GITHUB_CLIENT_SCOPE.split(',') : undefined,
  },
  async onSuccess(event, { user, tokens }) {
    const config = useRuntimeConfig(event);
    const logger = console;

    // Compute app base from current callback/login path to avoid hardcoding prefixes
    // e.g. /copilot-metrics-viewer-hdi/auth/github/callback -> /copilot-metrics-viewer-hdi/
    const { pathname } = getRequestURL(event)
    const base = (pathname.includes('/auth/') ? pathname.split('/auth/')[0] : '/') + (pathname.endsWith('/') ? '' : '/')

    await setUserSession(event, {
      user: {
        githubId: user.id,
        name: user.name,
        avatarUrl: user.avatar_url
      },
      secure: {
        tokens,
        expires_at: new Date(Date.now() + tokens.expires_in * 1000)
      }
    }
    )

    // need to check if this is public app (no default org/team/ent)
    if (config.public.isPublicApp) {
      try {
        const installationsResponse = await fetch('https://api.github.com/user/installations', {
          headers: {
            Authorization: `token ${tokens.access_token}`,
            Accept: 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28'
          }
        });

        const data = await installationsResponse.json() as { installations: Array<{ account: { login: string } }> };
        const installations = data.installations;
        const organizations = installations.map(installation => installation.account.login);

        await setUserSession(event, {
          organizations
        });
        logger.info('User organizations:', organizations);

        if (organizations.length === 0) {
          console.error('No organizations found for the user.');
          return sendRedirect(event, `${base}?error=No organizations found for the user.`);
        }

        return sendRedirect(event, `${base}orgs/${organizations[0]}`);
      }
      catch (error: unknown) {
        logger.error('Error fetching installations:', error);
      }
    }

    return sendRedirect(event, base)
  },
  // Optional, will return a json error and 401 status code by default
  onError(event, error) {
    console.error('GitHub OAuth error:', error)
    const { pathname } = getRequestURL(event)
    const base = (pathname.includes('/auth/') ? pathname.split('/auth/')[0] : '/') + (pathname.endsWith('/') ? '' : '/')
    return sendRedirect(event, base)
  },
})