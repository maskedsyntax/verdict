import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'

import GameBoard from '@/components/GameBoard.vue'
import GameKeyboard from '@/components/GameKeyboard.vue'

describe('game controls', () => {
  it('shows committed feedback and the current guess', () => {
    const wrapper = mount(GameBoard, {
      props: {
        guesses: ['crate'],
        evaluations: [['miss', 'near', 'miss', 'hit', 'miss']],
        currentGuess: 'sh',
        revealingRow: null,
        shakeCount: 0,
      },
    })

    expect(wrapper.findAll('.game-row')).toHaveLength(6)
    expect(wrapper.findAll('.game-tile--near')).toHaveLength(1)
    expect(wrapper.text()).toContain('sh')
  })

  it('emits letters and actions from the on-screen keyboard', async () => {
    const wrapper = mount(GameKeyboard, { props: { grades: { a: 'hit' } } })

    await wrapper.get('button[aria-label="a, hit"]').trigger('click')
    await wrapper.get('button[aria-label="Submit guess"]').trigger('click')
    await wrapper.get('button[aria-label="Delete letter"]').trigger('click')

    expect(wrapper.emitted('letter')?.[0]).toEqual(['a'])
    expect(wrapper.emitted('enter')).toHaveLength(1)
    expect(wrapper.emitted('delete')).toHaveLength(1)
  })
})
