import { ref, onMounted, nextTick } from 'vue'

export function useClientHydration() {
  const isHydrated = ref(false)
  const isClient = ref(false)

  onMounted(async () => {
    isClient.value = true
    await nextTick()
    isHydrated.value = true
  })

  return {
    isHydrated,
    isClient
  }
}
