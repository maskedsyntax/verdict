import { answers } from '@/data/words'

export type Grade = 'miss' | 'near' | 'hit'
export type GameStatus = 'playing' | 'won' | 'lost'

export interface DailyPuzzle {
  id: string
  number: number
  dateKey: string
  answer: string
}

export interface StoredGame {
  puzzleId: string
  guesses: string[]
  evaluations: Grade[][]
  status: GameStatus
}

const DAY_IN_MS = 86_400_000
const EPOCH = Date.UTC(2026, 0, 1)

export function utcDateKey(date = new Date()): string {
  return date.toISOString().slice(0, 10)
}

export function getDailyPuzzle(date = new Date()): DailyPuzzle {
  const utcDay = Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate())
  const dayOffset = Math.floor((utcDay - EPOCH) / DAY_IN_MS)

  if (dayOffset < 0) {
    throw new Error('No Verdict puzzle exists before January 1, 2026.')
  }

  const dateKey = utcDateKey(date)
  return {
    id: `classic-${dateKey}`,
    number: dayOffset + 1,
    dateKey,
    answer: answers[dayOffset % answers.length],
  }
}

export function gradeGuess(answer: string, guess: string): Grade[] {
  if (answer.length !== guess.length) {
    throw new Error('Answer and guess must have the same length.')
  }

  const grades: Grade[] = Array.from({ length: guess.length }, () => 'miss')
  const remaining = new Map<string, number>()

  for (let index = 0; index < answer.length; index += 1) {
    if (answer[index] === guess[index]) {
      grades[index] = 'hit'
    } else {
      remaining.set(answer[index], (remaining.get(answer[index]) ?? 0) + 1)
    }
  }

  for (let index = 0; index < guess.length; index += 1) {
    if (grades[index] === 'hit') continue
    const count = remaining.get(guess[index]) ?? 0
    if (count > 0) {
      grades[index] = 'near'
      remaining.set(guess[index], count - 1)
    }
  }

  return grades
}

export function mergeKeyboardGrades(guesses: string[], evaluations: Grade[][]): Record<string, Grade> {
  const rank: Record<Grade, number> = { miss: 0, near: 1, hit: 2 }
  const merged: Record<string, Grade> = {}

  guesses.forEach((guess, guessIndex) => {
    guess.split('').forEach((letter, letterIndex) => {
      const grade = evaluations[guessIndex]?.[letterIndex]
      if (grade && (merged[letter] === undefined || rank[grade] > rank[merged[letter]])) {
        merged[letter] = grade
      }
    })
  })

  return merged
}

export function shareGrid(puzzle: DailyPuzzle, evaluations: Grade[][], won: boolean, publicUrl?: string): string {
  const symbols: Record<Grade, string> = {
    miss: '⬛',
    near: '🟨',
    hit: '🟩',
  }
  const score = won ? evaluations.length : 'X'
  const rows = evaluations.map((row) => row.map((grade) => symbols[grade]).join(''))
  return [
    `VERDICT #${puzzle.number} ${score}/6`,
    '',
    ...rows,
    '',
    publicUrl ? `Play Verdict: ${publicUrl}` : 'Play Verdict',
  ].join('\n')
}

export function millisecondsUntilNextPuzzle(now = new Date()): number {
  const next = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1)
  return Math.max(0, next - now.getTime())
}

export function formatCountdown(milliseconds: number): string {
  const totalSeconds = Math.max(0, Math.floor(milliseconds / 1000))
  const hours = Math.floor(totalSeconds / 3600)
  const minutes = Math.floor((totalSeconds % 3600) / 60)
  const seconds = totalSeconds % 60
  return [hours, minutes, seconds].map((part) => String(part).padStart(2, '0')).join(':')
}
