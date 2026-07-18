import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

import { validWords } from '@/data/words'
import { getDailyPuzzle, gradeGuess, mergeKeyboardGrades, type GameStatus, type Grade } from '@/lib/game'
import { loadGame, recordCompletedGame, saveGame } from '@/lib/storage'

const MAX_GUESSES = 6
const WORD_LENGTH = 5

export function useDailyGame() {
  const puzzle = getDailyPuzzle()
  const restored = loadGame(puzzle.id)
  const guesses = ref<string[]>(restored?.guesses ?? [])
  const evaluations = ref<Grade[][]>(restored?.evaluations ?? [])
  const restoredStatus: GameStatus = restored?.status === 'playing' && restored.guesses.at(-1) === puzzle.answer
    ? 'won'
    : restored?.status === 'playing' && restored.guesses.length >= MAX_GUESSES
      ? 'lost'
      : restored?.status ?? 'playing'
  const status = ref<GameStatus>(restoredStatus)
  const currentGuess = ref('')
  const message = ref('')
  const shakeCount = ref(0)
  const revealingRow = ref<number | null>(null)
  const freshCompletion = ref(false)
  let messageTimer: number | undefined
  let revealTimer: number | undefined

  if (restoredStatus !== 'playing') {
    recordCompletedGame(puzzle.dateKey, restoredStatus, guesses.value.length)
  }

  const keyboardGrades = computed(() => mergeKeyboardGrades(guesses.value, evaluations.value))

  function persist(): void {
    saveGame({
      puzzleId: puzzle.id,
      guesses: guesses.value,
      evaluations: evaluations.value,
      status: status.value,
    })
  }

  function announce(text: string): void {
    message.value = text
    window.clearTimeout(messageTimer)
    messageTimer = window.setTimeout(() => {
      message.value = ''
    }, 2200)
  }

  function addLetter(letter: string): void {
    if (status.value !== 'playing' || revealingRow.value !== null || currentGuess.value.length >= WORD_LENGTH) return
    currentGuess.value += letter.toLowerCase()
  }

  function removeLetter(): void {
    if (status.value !== 'playing' || revealingRow.value !== null) return
    currentGuess.value = currentGuess.value.slice(0, -1)
  }

  function submitGuess(): void {
    if (status.value !== 'playing' || revealingRow.value !== null) return
    if (currentGuess.value.length !== WORD_LENGTH) {
      shakeCount.value += 1
      announce('Not enough letters')
      return
    }
    if (!validWords.has(currentGuess.value)) {
      shakeCount.value += 1
      announce('Not in the word list')
      return
    }

    const guess = currentGuess.value
    const evaluation = gradeGuess(puzzle.answer, guess)
    guesses.value.push(guess)
    evaluations.value.push(evaluation)
    currentGuess.value = ''
    revealingRow.value = guesses.value.length - 1
    persist()

    revealTimer = window.setTimeout(() => {
      revealingRow.value = null
      if (guess === puzzle.answer) {
        status.value = 'won'
        freshCompletion.value = true
        announce(['Sharp.', 'Case closed.', 'Unanimous.', 'Guilty of genius.'][Math.min(guesses.value.length - 1, 3)])
      } else if (guesses.value.length >= MAX_GUESSES) {
        status.value = 'lost'
        freshCompletion.value = true
        announce(puzzle.answer.toUpperCase())
      }

      persist()
      if (status.value !== 'playing') {
        recordCompletedGame(puzzle.dateKey, status.value, guesses.value.length)
      }
    }, 1150)
  }

  function handleKeydown(event: KeyboardEvent): void {
    if (event.metaKey || event.ctrlKey || event.altKey) return
    if (event.key === 'Enter') submitGuess()
    else if (event.key === 'Backspace' || event.key === 'Delete') removeLetter()
    else if (/^[a-zA-Z]$/.test(event.key)) addLetter(event.key)
  }

  onMounted(() => window.addEventListener('keydown', handleKeydown))
  onBeforeUnmount(() => {
    window.removeEventListener('keydown', handleKeydown)
    window.clearTimeout(messageTimer)
    window.clearTimeout(revealTimer)
  })

  return {
    puzzle,
    guesses,
    evaluations,
    status,
    currentGuess,
    message,
    shakeCount,
    revealingRow,
    freshCompletion,
    keyboardGrades,
    addLetter,
    removeLetter,
    submitGuess,
  }
}
