import { describe, expect, it } from 'vitest'

import {
  formatCountdown,
  getDailyPuzzle,
  gradeGuess,
  mergeKeyboardGrades,
  millisecondsUntilNextPuzzle,
  shareGrid,
} from '@/lib/game'

describe('daily puzzle', () => {
  it('matches the shared Dart epoch and answer order', () => {
    expect(getDailyPuzzle(new Date('2026-01-01T23:59:59Z'))).toMatchObject({
      id: 'classic-2026-01-01',
      number: 1,
      answer: 'filmy',
    })
    expect(getDailyPuzzle(new Date('2026-01-02T00:00:00Z'))).toMatchObject({
      id: 'classic-2026-01-02',
      number: 2,
      answer: 'panda',
    })
  })
})

describe('guess grading', () => {
  it('marks hits, near letters, and misses', () => {
    expect(gradeGuess('shire', 'raise')).toEqual(['near', 'miss', 'hit', 'near', 'hit'])
  })

  it('does not over-credit duplicate letters', () => {
    expect(gradeGuess('apple', 'allee')).toEqual(['hit', 'near', 'miss', 'miss', 'hit'])
    expect(gradeGuess('cacao', 'aaaaa')).toEqual(['miss', 'hit', 'miss', 'hit', 'miss'])
  })

  it('keeps the most informative keyboard grade', () => {
    expect(mergeKeyboardGrades(
      ['store', 'shire'],
      [
        ['hit', 'near', 'miss', 'near', 'hit'],
        ['hit', 'hit', 'hit', 'hit', 'hit'],
      ],
    )).toMatchObject({ s: 'hit', h: 'hit', i: 'hit', r: 'hit', e: 'hit', t: 'near', o: 'miss' })
  })
})

describe('result sharing and countdown', () => {
  it('builds a spoiler-safe grid', () => {
    const puzzle = getDailyPuzzle(new Date('2026-01-01T12:00:00Z'))
    const result = shareGrid(puzzle, [['miss', 'near', 'hit', 'miss', 'hit']], true)

    expect(result).toContain('VERDICT #1 1/6')
    expect(result).toContain('⬛🟨🟩⬛🟩')
    expect(result.toLowerCase()).not.toContain(puzzle.answer)
  })

  it('calculates the next UTC boundary', () => {
    const remaining = millisecondsUntilNextPuzzle(new Date('2026-07-19T22:58:57Z'))
    expect(formatCountdown(remaining)).toBe('01:01:03')
  })
})
