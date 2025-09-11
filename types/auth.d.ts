declare module '#auth-utils' {
  interface User {
    githubId: number
    name: string
    avatarUrl: string
  }
}

declare module 'nuxt-auth-utils' {
  interface User {
    githubId: number
    name: string
    avatarUrl: string
  }
}
