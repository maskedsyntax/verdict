import type { GameStatus, StoredGame } from '@/lib/game'

export interface PlayerStats {
  gamesPlayed: number
  wins: number
  currentStreak: number
  maxStreak: number
  distribution: number[]
  lastCompletedDate: string | null
  lastWinDate: string | null
}

const STATS_KEY = 'verdict:stats:v1'
const GAME_PREFIX = 'verdict:game:v1:'

export const emptyStats = (): PlayerStats => ({
  gamesPlayed: 0,
  wins: 0,
  currentStreak: 0,
  maxStreak: 0,
  distribution: [0, 0, 0, 0, 0, 0],
  lastCompletedDate: null,
  lastWinDate: null,
})

function readJson<T>(key: string): T | null {
  try {
    const value = window.localStorage.getItem(key)
    return value ? JSON.parse(value) as T : null
  } catch {
    return null
  }
}

export function loadGame(puzzleId: string): StoredGame | null {
  const game = readJson<StoredGame>(`${GAME_PREFIX}${puzzleId}`)
  if (!game || game.puzzleId !== puzzleId || !Array.isArray(game.guesses)) return null
  return game
}

export function saveGame(game: StoredGame): void {
  try {
    window.localStorage.setItem(`${GAME_PREFIX}${game.puzzleId}`, JSON.stringify(game))
  } catch {
    // Private browsing restrictions should not prevent a game from continuing.
  }
}

export function loadStats(): PlayerStats {
  const stored = readJson<Partial<PlayerStats>>(STATS_KEY)
  const defaults = emptyStats()
  if (!stored) return defaults

  return {
    ...defaults,
    ...stored,
    distribution: Array.isArray(stored.distribution)
      ? [...stored.distribution, 0, 0, 0, 0, 0, 0].slice(0, 6)
      : defaults.distribution,
  }
}

function previousUtcDate(dateKey: string): string {
  const date = new Date(`${dateKey}T00:00:00Z`)
  date.setUTCDate(date.getUTCDate() - 1)
  return date.toISOString().slice(0, 10)
}

export function recordCompletedGame(dateKey: string, status: Exclude<GameStatus, 'playing'>, guesses: number): PlayerStats {
  const stats = loadStats()
  if (stats.lastCompletedDate === dateKey) return stats

  stats.gamesPlayed += 1
  stats.lastCompletedDate = dateKey

  if (status === 'won') {
    stats.wins += 1
    stats.currentStreak = stats.lastWinDate === previousUtcDate(dateKey)
      ? stats.currentStreak + 1
      : 1
    stats.maxStreak = Math.max(stats.maxStreak, stats.currentStreak)
    stats.lastWinDate = dateKey
    if (guesses >= 1 && guesses <= 6) stats.distribution[guesses - 1] += 1
  } else {
    stats.currentStreak = 0
  }

  try {
    window.localStorage.setItem(STATS_KEY, JSON.stringify(stats))
  } catch {
    return stats
  }
  window.dispatchEvent(new CustomEvent('verdict:stats-updated'))
  return stats
}
