import { beforeEach, describe, expect, it } from 'vitest'

import { loadGame, loadStats, recordCompletedGame, saveGame } from '@/lib/storage'

const values = new Map<string, string>()
const testStorage: Storage = {
  get length() { return values.size },
  clear: () => values.clear(),
  getItem: (key) => values.get(key) ?? null,
  key: (index) => [...values.keys()][index] ?? null,
  removeItem: (key) => { values.delete(key) },
  setItem: (key, value) => { values.set(key, value) },
}

Object.defineProperty(window, 'localStorage', {
  configurable: true,
  value: testStorage,
})

describe('local game storage', () => {
  beforeEach(() => window.localStorage.clear())

  it('round-trips a daily game', () => {
    saveGame({
      puzzleId: 'classic-2026-07-19',
      guesses: ['crate'],
      evaluations: [['miss', 'near', 'miss', 'hit', 'miss']],
      status: 'playing',
    })

    expect(loadGame('classic-2026-07-19')).toMatchObject({ guesses: ['crate'], status: 'playing' })
    expect(loadGame('classic-2026-07-20')).toBeNull()
  })
})

describe('player statistics', () => {
  beforeEach(() => window.localStorage.clear())

  it('records wins and consecutive UTC streaks once per day', () => {
    recordCompletedGame('2026-07-18', 'won', 4)
    recordCompletedGame('2026-07-19', 'won', 2)
    recordCompletedGame('2026-07-19', 'won', 2)

    expect(loadStats()).toMatchObject({
      gamesPlayed: 2,
      wins: 2,
      currentStreak: 2,
      maxStreak: 2,
      distribution: [0, 1, 0, 1, 0, 0],
    })
  })

  it('resets the current streak after a loss', () => {
    recordCompletedGame('2026-07-18', 'won', 3)
    recordCompletedGame('2026-07-19', 'lost', 6)

    expect(loadStats()).toMatchObject({ gamesPlayed: 2, wins: 1, currentStreak: 0, maxStreak: 1 })
  })
})
