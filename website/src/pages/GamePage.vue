<script setup lang="ts">
import { BarChart3, CircleHelp, Scale } from '@lucide/vue'
import { computed, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'

import GameBoard from '@/components/GameBoard.vue'
import GameKeyboard from '@/components/GameKeyboard.vue'
import ResultPanel from '@/components/ResultPanel.vue'
import { useDailyGame } from '@/composables/useDailyGame'
import { shareGrid } from '@/lib/game'

const game = useDailyGame()
const resultOpen = ref(game.status.value !== 'playing')
const shareLabel = ref('Share verdict')

const gameStatusLabel = computed(() => {
  if (game.status.value === 'won') return `Solved in ${game.guesses.value.length}`
  if (game.status.value === 'lost') return 'Case closed'
  return `${6 - game.guesses.value.length} guesses left`
})

watch(game.freshCompletion, (completed) => {
  if (completed) resultOpen.value = true
})

async function shareResult(): Promise<void> {
  const text = shareGrid(
    game.puzzle,
    game.evaluations.value,
    game.status.value === 'won',
    window.location.origin,
  )

  try {
    if (navigator.share) {
      await navigator.share({ title: `Verdict #${game.puzzle.number}`, text })
      shareLabel.value = 'Shared'
    } else {
      await navigator.clipboard.writeText(text)
      shareLabel.value = 'Copied to clipboard'
    }
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') return
    shareLabel.value = 'Could not share'
  }

  window.setTimeout(() => {
    shareLabel.value = 'Share verdict'
  }, 2200)
}
</script>

<template>
  <div class="game-page">
    <div class="game-topbar">
      <RouterLink class="game-topbar-link" to="/how-to-play">
        <CircleHelp :size="18" /> Rules
      </RouterLink>
      <div class="puzzle-chip">
        <Scale :size="17" :stroke-width="3" /> Daily · #{{ game.puzzle.number }}
      </div>
      <RouterLink class="game-topbar-link" to="/stats">
        <BarChart3 :size="18" /> Stats
      </RouterLink>
    </div>

    <section class="game-stage" aria-labelledby="game-title">
      <div class="game-heading">
        <div>
          <span class="game-mode">Classic docket</span>
          <h1 id="game-title">Deliver your verdict.</h1>
        </div>
        <span class="guesses-left">{{ gameStatusLabel }}</span>
      </div>

      <div class="game-message" role="status" aria-live="assertive">
        <span v-if="game.message.value">{{ game.message.value }}</span>
      </div>

      <GameBoard
        :guesses="game.guesses.value"
        :evaluations="game.evaluations.value"
        :current-guess="game.currentGuess.value"
        :revealing-row="game.revealingRow.value"
        :shake-count="game.shakeCount.value"
      />

      <GameKeyboard
        :grades="game.keyboardGrades.value"
        :disabled="game.status.value !== 'playing' || game.revealingRow.value !== null"
        @letter="game.addLetter"
        @delete="game.removeLetter"
        @enter="game.submitGuess"
      />

      <button
        v-if="game.status.value !== 'playing'"
        class="button button--white view-results"
        type="button"
        @click="resultOpen = true"
      >
        View today’s result
      </button>
      <p class="game-footnote">A new case opens every day at midnight UTC.</p>
    </section>

    <ResultPanel
      v-if="resultOpen && game.status.value !== 'playing'"
      :status="game.status.value"
      :answer="game.puzzle.answer"
      :guess-count="game.guesses.value.length"
      :puzzle-number="game.puzzle.number"
      :share-label="shareLabel"
      @close="resultOpen = false"
      @share="shareResult"
    />
  </div>
</template>

<style scoped>
.game-page {
  min-height: 860px;
  padding-bottom: 56px;
  background:
    linear-gradient(90deg, transparent calc(50% - 300px), rgb(23 23 23 / 7%) calc(50% - 300px), rgb(23 23 23 / 7%) calc(50% - 297px), transparent calc(50% - 297px)),
    linear-gradient(90deg, transparent calc(50% + 297px), rgb(23 23 23 / 7%) calc(50% + 297px), rgb(23 23 23 / 7%) calc(50% + 300px), transparent calc(50% + 300px));
}

.game-topbar {
  display: grid;
  width: min(100% - 36px, 680px);
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  margin: 0 auto;
  padding: 22px 0 10px;
}

.game-topbar-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 0.82rem;
  font-weight: 700;
  text-decoration: none;
}

.game-topbar-link:last-child {
  justify-self: end;
}

.game-topbar-link:hover {
  text-decoration: underline;
  text-decoration-thickness: 2px;
  text-underline-offset: 4px;
}

.puzzle-chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 10px;
  border: 2px solid var(--ink);
  background: var(--yellow);
  box-shadow: 3px 3px 0 var(--ink);
  font-size: 0.73rem;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

.game-stage {
  width: min(100% - 24px, 610px);
  margin: 20px auto 0;
  padding: clamp(20px, 4vw, 36px);
  border: var(--border);
  background: rgb(255 253 248 / 90%);
  box-shadow: 8px 8px 0 var(--ink);
}

.game-heading {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 20px;
  padding-bottom: 18px;
  border-bottom: 2px solid var(--ink);
}

.game-mode {
  display: block;
  margin-bottom: 7px;
  color: var(--green-deep);
  font-size: 0.72rem;
  font-weight: 700;
  letter-spacing: 0.13em;
  text-transform: uppercase;
}

.game-heading h1 {
  margin: 0;
  font-size: clamp(1.8rem, 6vw, 2.75rem);
}

.guesses-left {
  flex: none;
  font-size: 0.76rem;
  font-weight: 700;
  text-transform: uppercase;
}

.game-message {
  display: grid;
  height: 42px;
  place-items: center;
  font-size: 0.84rem;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

.game-message span {
  padding: 5px 10px;
  border: 2px solid var(--ink);
  background: var(--ink);
  color: var(--white);
}

.view-results {
  width: 100%;
  margin-top: 22px;
}

.game-footnote {
  margin: 18px 0 0;
  color: #68645f;
  font-size: 0.75rem;
  text-align: center;
}

@media (max-width: 620px) {
  .game-page {
    min-height: auto;
    padding-bottom: 28px;
    background: none;
  }

  .game-stage {
    margin-top: 8px;
    border-right: 0;
    border-left: 0;
    box-shadow: 0 6px 0 var(--ink);
  }

  .game-heading {
    align-items: flex-start;
    flex-direction: column;
    gap: 8px;
  }
}
</style>
