/**
 * Mock implementation of useUserSession for when authentication is disabled
 * This provides a consistent interface without requiring actual authentication
 */
export const useUserSession = () => {
  const loggedIn = ref(false)
  const user = ref(null)
  
  const clear = () => {
    loggedIn.value = false
    user.value = null
  }
  
  const update = (newUser: any) => {
    loggedIn.value = true
    user.value = newUser
  }
  
  return {
    loggedIn: readonly(loggedIn),
    user: readonly(user),
    clear,
    update
  }
}
