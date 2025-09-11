import type { FetchError } from 'ofetch';

export default defineOAuthGitHubEventHandler({
  config: {
    scope: process.env.NUXT_OAUTH_GITHUB_CLIENT_SCOPE ? process.env.NUXT_OAUTH_GITHUB_CLIENT_SCOPE.split(',') : undefined,
  },
  async onSuccess(event: any, { user, tokens }: any) {
    const config = useRuntimeConfig(event);
    const logger = console;

    await setUserSession(event, {
      user: {
        githubId: user.id,
        name: user.name,
        avatarUrl: user.avatar_url
      },
      secure: {
        tokens,
        expires_at: new Date(Date.now() + (tokens.expires_in || 3600) * 1000)
      }
    }
    )

    // need to check if this is public app (no default org/team/ent)
    if (config.public.isPublicApp) {
      try {
        const installationsResponse = await $fetch('https://api.github.com/user/installations', {
          headers: {
            Authorization: `token ${tokens.access_token}`,
            Accept: 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28'
          }
        }) as { installations: Array<{ account: { login: string } }> };

        const installations = installationsResponse.installations;
        const organizations = installations.map(installation => installation.account.login);

        await setUserSession(event, {
          organizations
        });
        logger.info('User organizations:', organizations);

        if (organizations.length === 0) {
          console.error('No organizations found for the user.');
          return sendRedirect(event, '/?error=No organizations found for the user.');
        }

        return sendRedirect(event, `/orgs/${organizations[0]}`);
      }
      catch (error: any) {
        logger.error('Error fetching installations:', error);
      }
    }

    return sendRedirect(event, '/')
  },
  // Optional, will return a json error and 401 status code by default
  onError(event: any, error: any) {
    console.error('GitHub OAuth error:', error)
    
    // Log detailed error information for debugging
    if (error.message) {
      console.error('Error message:', error.message)
    }
    if (error.status) {
      console.error('Error status:', error.status)
    }
    
    // Redirect with more specific error information
    const errorMessage = encodeURIComponent(
      error.message || 'Error de autenticación con GitHub. Por favor, intenta nuevamente.'
    )
    return sendRedirect(event, `/?error=${errorMessage}`)
  }
})
