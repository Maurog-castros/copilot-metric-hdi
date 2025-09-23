import { NuxtAuthHandler } from '#auth'
import GithubProvider from 'next-auth/providers/github'

export default NuxtAuthHandler({
  secret: useRuntimeConfig().auth?.secret,
  providers: [
    GithubProvider({
      clientId: useRuntimeConfig().github?.clientId,
      clientSecret: useRuntimeConfig().github?.clientSecret
    })
  ],
})


