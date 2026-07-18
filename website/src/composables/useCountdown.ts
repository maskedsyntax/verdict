import { onBeforeUnmount, onMounted, ref } from 'vue'

import { formatCountdown, millisecondsUntilNextPuzzle } from '@/lib/game'

export function useCountdown() {
  const countdown = ref(formatCountdown(millisecondsUntilNextPuzzle()))
  let timer: number | undefined

  const update = () => {
    countdown.value = formatCountdown(millisecondsUntilNextPuzzle())
  }

  onMounted(() => {
    timer = window.setInterval(update, 1000)
  })
  onBeforeUnmount(() => window.clearInterval(timer))

  return countdown
}
